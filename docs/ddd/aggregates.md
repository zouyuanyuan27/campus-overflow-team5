# Lab 3 · 聚合识别清单

> 作者：张嘉雨（`@ember216`）　|　日期：2026-10-28　|　状态：**v1.0 底稿，待 Lab 3 现场校准**
> 手册 Lab 3 Step 3 提交物 3：「聚合识别清单 Markdown（含聚合名、根实体、关键不变式）」
> 依据：`backend/co-*/co-*-domain/src/main/java/.../domain/*.java` 的 Javadoc 与约束代码（类尚未实现，但不变式已写在类注释里）。

---

## 一、聚合总览

| 聚合 | 根实体 | 限界上下文 | 表名前缀 | 关键不变式 |
| --- | --- | --- | --- | --- |
| `User` | User | Identity | `id_` | 学号唯一、昵称全局唯一、认证状态受控 |
| `Course` | Course | Identity | `id_` | 学期 + 课程编号唯一；成员角色单一 |
| `Question` | Question | QA | `qa_` | 最多一个采纳答案且不可逆、删除后只读 |
| `Answer` | Answer | QA | `qa_` | 必须属于未删除的问题；采纳状态由 Question 单一持有 |
| `Vote` | Vote | QA | `qa_` | 一人一内容一票，值 ±1，撤销即删除 |
| `Comment` | Comment | QA | `qa_` | 必须挂在未删除的问题/回答上 |
| `ReputationAccount` | ReputationAccount | Reputation | `rep_` | 余额由账目累加得出，不可直接改写 |
| `BadgeAward` | BadgeAward | Reputation | `rep_` | 同一徽章对同一用户在同一学期只授予一次 |
| `Bounty` | Bounty | Reputation | `rep_` | 悬赏金额开启时冻结、关闭时结算，不可超额支付 |
| `Notification` | Notification | Discovery | `dis_` | 只读投影，随事件生成，不反向影响业务 |

---

## 二、逐个聚合详解

### Identity 上下文

**1. `User`（用户聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `User` |
| 值对象 / 内部属性 | `username`（学号/工号）、`displayName`、`email`、`passwordHash`、`role`、`status`、`verified`、`college`、`className` |
| 关键不变式 | ① `username` 匹配 `^[A-Za-z0-9]{4,20}$` 且全局唯一；② `displayName` 全局唯一（用于 `@` 提及）；③ `email` 格式合法且唯一；④ `verified` 只能由学院管理员置位；⑤ `username` 属个人信息，不对外展示（对外只用 `displayName`） |
| 一致性边界 | 单用户。注册、认证、封禁各自独立事务 |
| 与外部的引用 | 其他上下文只持有 `userId`，不持有 User 对象 |
| 代码位置 | `co-identity-domain/.../domain/User.java` |

**2. `Course` / `CourseMember`（课程聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Course`（成员作为聚合内实体 `CourseMember`） |
| 内部属性 | `courseId`、`AcademicTerm`、`CourseMember`（userId + `CourseRole`） |
| 关键不变式 | ① 同一学期同一课程编号唯一；② 同一用户在同一课程中只能有一种 `CourseRole`（STUDENT / TEACHER / TA）；③ 课程管理者（教师/助教）身份决定其跨聚合的删除与认证权限 |
| 一致性边界 | 单课程。成员增减与课程信息修改同事务 |
| 代码位置 | `co-identity-domain/.../domain/Course.java`、`CourseMember.java`、`CourseRole.java` |

### QA 上下文

**3. `Question`（问题聚合根）—— 核心不变式最密集**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Question` |
| 值对象 | `Title`（10–150 字符）、`MarkdownBody`、`Tags`（去重后 1–5 个 `TagName`，每个 1–30 字符、小写） |
| 关键不变式 | ① **最多只有一个被采纳的答案，且采纳后不可更改**；② 只有提问者或课程管理者（教师/助教/管理员）可以采纳；③ 已删除的问题不能再被回答、编辑或采纳；④ 提问者只能删除**尚无回答**的问题，课程管理者可删除任意问题；⑤ 每个问题必须带 1–5 个标签 |
| 反规范化字段 | `score` / `answerCount` / `viewCount` —— **不由聚合回写**，由仓储以原子 `UPDATE` 维护（ADR-008），避免读-改-写覆盖并发增量 |
| 一致性边界 | 单问题。采纳（`accept`）是 Question 与 Answer 之间的**跨聚合操作**，由应用服务编排：Question 改 `acceptedAnswerId` → 发布 `AnswerAccepted` → Reputation 异步响应 |
| 代码位置 | `co-qa-domain/.../domain/Question.java` |

**4. `Answer`（回答聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Answer` |
| 值对象 | `MarkdownBody`、状态字段 `endorsedBy`（教师认证人） |
| 关键不变式 | ① 必须属于一个未删除的问题（提交时校验 `Question`）；② **「是否被采纳」不在本聚合存储**，由 `Question.acceptedAnswerId` 单一事实来源持有；③ 教师认证（`endorse`）只能由课程管理者执行；④ 作者或课程管理者可编辑/删除 |
| 一致性边界 | 单回答。独立于 Question 聚合以降低并发冲突（高频回答不会锁住问题行） |
| 与 Question 的引用 | 通过 `questionId` 引用，不持有 Question 对象引用 |
| 代码位置 | `co-qa-domain/.../domain/Answer.java` |

**5. `Vote`（投票聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Vote` |
| 内部属性 | `voterId`、`targetType`（QUESTION / ANSWER）、`targetId`、`value` |
| 关键不变式 | ① 同一用户对同一内容**仅一票**（数据库唯一约束兜底）；② 值为 `+1` 或 `-1`；③ 撤销 = 删除（不做 0 值）；④ 改投（`change`）返回原值供声誉冲正；⑤ 不能对自己的内容投票（业务规则，现场确认是否在本聚合或应用服务校验） |
| 一致性边界 | 单张票。投票不直接改内容分数，分数由计数器原子维护 |
| 代码位置 | `co-qa-domain/.../domain/Vote.java` |

**6. `Comment`（评论聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Comment` |
| 关键不变式 | ① 必须挂在未删除的问题或回答上；② 评论不参与投票与声誉（v1.0 范围，现场确认） |
| 一致性边界 | 单条评论 |

### Reputation 上下文

**7. `ReputationAccount`（声誉账户聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `ReputationAccount` |
| 内部实体 | `LedgerEntry`（账目明细，含 `ReputationReason`、分值、时间） |
| 关键不变式 | ① **余额只能由账目累加得出，不可直接改写**；② 每条账目必须对应一个 `ReputationReason`；③ 规则调整时只追加冲正账目，**不改写历史**（热点 H2） |
| 一致性边界 | 单账户。账目追加与余额更新同事务 |
| 代码位置 | `co-reputation-domain/.../ReputationAccount.java`、`LedgerEntry.java`、`ReputationRulebook.java` |

**8. `BadgeAward`（徽章授予聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `BadgeAward` |
| 关键不变式 | ① 同一 `BadgeType` 对同一用户在同一 `AcademicTerm` 只授予一次；② 授予策略由 `BadgePolicy` 判定，授予后不可逆（除违规回收） |
| 一致性边界 | 单条授予记录 |

**9. `Bounty`（悬赏聚合根）**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Bounty` |
| 内部属性 | 金额、状态 `BountyStatus`（OPEN / AWARDED / CLOSED）、截止学期 `AcademicTerm` |
| 关键不变式 | ① 开启时从悬赏者账户**冻结**声誉，不可超额承诺；② 只能发放一次（`AWARDED` 后不可再发）；③ 关闭时未发放部分退回；④ 过期处理由定时任务触发（热点 H1） |
| 一致性边界 | 单笔悬赏。冻结/发放/退回涉及与 `ReputationAccount` 的协作，由应用服务编排 |

### Discovery 上下文（只读投影）

**10. `Notification` / `SearchDocument`**

| 项 | 内容 |
| --- | --- |
| 根实体 | `Notification`、`SearchDocument` |
| 性质 | **读模型（Read Model）**，由订阅集成事件构建，不是业务聚合 |
| 关键不变式 | ① 只读投影，不接受用户命令直接修改；② 可重放重建（事件重放后结果一致）；③ `MentionParser` 从正文解析 `@提及` 生成通知 |
| 一致性边界 | 最终一致（热点 H6，建议 SLA 5 秒） |

---

## 三、设计取舍说明（评分点：聚合边界与不变式定义清晰度）

1. **Answer 独立于 Question 而不是作为 Question 的内部实体**：回答是高频、并发写操作；若作为 Question 的内部集合，每次回答都会锁住整个问题聚合，冲突率与事务粒度都不合理。代价是「采纳」成为跨聚合操作，需要应用服务编排 + 事件驱动。
2. **「是否被采纳」只存在 Question 一处**：避免双写不一致。`Answer` 不存 `accepted` 字段，查询采纳状态时以 `Question.acceptedAnswerId` 为准。
3. **计数器（score / answerCount / viewCount）不由聚合维护**：ADR-008 明确由原子 SQL `UPDATE` 维护，避免读-改-写覆盖并发增量——这是本项目区别于教科书示例的关键决策，Lab 3 现场应讲清楚。
4. **声誉账目化**：余额 = 账目累加，任何变动留痕，支持冲正与审计，直接支撑热点 H2/H3 的处置。
5. **Vote 独立成聚合**：一人一票的唯一约束可以落到数据库唯一索引，聚合层面只管 ±1 与改投。

---

## 四、现场待确认项

- [ ] 投票「不能投自己的内容」在哪一层校验（聚合 or 应用服务）
- [ ] 评论是否参与声誉与投票
- [ ] 问题浏览量是否发领域事件（倾向不发）
- [ ] 悬赏过期规则（热点 H1）
