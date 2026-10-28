# Lab 3 · 事件风暴底稿 v1.0

> 作者：张嘉雨（`@ember216`）　|　日期：2026-10-28　|　状态：**现场前的准备底稿，待 Lab 3 现场校准**
> **本人名下任务：L3-04「为每个事件添加蓝色命令卡片（谁触发的）」→ 见 §三 命令清单**（命令 / 触发角色 / 产生事件三列齐全）；L3-09「识别读模型」→ 见 `docs/ddd/read-models.md`
> 用途：Lab 3 Step 1–Step 2 便利贴的预先清单，现场直接照此铺贴、再增删。
> 依据：`backend/co-*/**/api/event/*Event.java`（代码中已定义的集成事件）+ `docs/adr/001`（四上下文）+ ADR-002（事务性发件箱）。
> 手册 Lab 3 目标：事件识别完整性 25%、上下文划分合理性 30%、聚合边界与不变式 25%、统一语言一致性 20%。

---

## 一、Big Picture 事件清单（橙色便利贴 · 全部用过去时）

### 1.1 代码实现中已存在的事件（14 个，可直接贴）

| # | 领域事件（English） | 中文 | 产生上下文 | 触发命令 |
| --- | --- | --- | --- | --- |
| E01 | `UserRegistered` | 用户已注册 | Identity | `RegisterUser` |
| E02 | `QuestionPosted` | 问题已发布 | QA | `PostQuestion` |
| E03 | `QuestionEdited` | 问题已编辑 | QA | `EditQuestion` |
| E04 | `AnswerSubmitted` | 回答已提交 | QA | `SubmitAnswer` |
| E05 | `AnswerEndorsed` | 回答已被教师认证 | QA | `EndorseAnswer` |
| E06 | `AnswerAccepted` | 回答已被采纳 | QA | `AcceptAnswer` |
| E07 | `CommentPosted` | 评论已发布 | QA | `PostComment` |
| E08 | `VoteCast` | 投票已产生 | QA | `CastVote` |
| E09 | `ContentDeleted` | 内容已删除 | QA | `DeleteContent` |
| E10 | `ReputationChanged` | 声誉已变动 | Reputation | （响应 E06/E08 等） |
| E11 | `BadgeAwarded` | 徽章已授予 | Reputation | （策略自动判定） |
| E12 | `BountyOpened` | 悬赏已开启 | Reputation | `OpenBounty` |
| E13 | `BountyAwarded` | 悬赏已发放 | Reputation | `AwardBounty` |
| E14 | `BountyClosed` | 悬赏已关闭 | Reputation | `CloseBounty` |

### 1.2 现场需讨论补贴的事件（业务上必要，代码尚未定义）

| # | 候选事件 | 理由 | 处理建议 |
| --- | --- | --- | --- |
| C01 | `UserVerified` | 学院管理员完成校园身份认证，属于 Identity 的关键状态变化 | 现场确认后补 `co-identity-api` 事件 |
| C02 | `QuestionViewed` | 浏览量是反规范化计数器，高频；是否发事件需权衡（可能只做计数不走发件箱） | **倾向不发事件**，直接原子 UPDATE，现场确认 |
| C03 | `QuestionClosed` / `QuestionReopened` | 课程结束后问题关闭，未见代码实现 | 现场确认是否纳入 Sprint 1 范围 |
| C04 | `ContentFlagged` | 举报/违规标记，Reputation 扣分依据 | 现场确认，若纳入需新增 `Flag` 聚合 |
| C05 | `NotificationSent` | 通知已送达 | 属 Discovery 内部，建议**不作为集成事件**（避免回环） |

> ⚠️ 手册陷阱提示：事件粒度过粗（如"用户操作完成"）是扣分点。本表全部使用业务术语 + 过去时，现场新增事件须沿用此格式。

---

## 二、时间线排列（铺墙顺序）

```
[注册期]  UserRegistered ──► UserVerified
              │
              ▼
[提问期]  QuestionPosted ──► QuestionEdited ──► (QuestionViewed?)
              │
              ▼
[回答期]  AnswerSubmitted ──► AnswerEdited? ──► CommentPosted
              │                    │
              │                    ▼
              │              AnswerEndorsed（教师认证）
              ▼
[评价期]  VoteCast ──► AnswerAccepted
              │              │
              ▼              ▼
[激励期]  ReputationChanged ──► BadgeAwarded
              │
              ▼
[悬赏期]  BountyOpened ──► BountyAwarded ──► BountyClosed
              │
              ▼
[消亡期]  ContentDeleted
```

**系统边界事件**（与外部系统交互）：`UserRegistered`（校园统一身份认证）、`UserVerified`（学院管理员审核）、`BadgeAwarded`（可能触发邮件通知）。

---

## 三、命令清单（蓝色便利贴）

| 命令 | 触发角色 | 产生事件 | 所属上下文 |
| --- | --- | --- | --- |
| `RegisterUser` | 学生/教师 | E01 | Identity |
| `VerifyCampusIdentity` | 学院管理员 | C01 | Identity |
| `PostQuestion` | 学生 | E02 | QA |
| `EditQuestion` | 提问者 / 课程管理者 | E03 | QA |
| `SubmitAnswer` | 学生 | E04 | QA |
| `EndorseAnswer`（教师认证） | 教师 / 助教 | E05 | QA |
| `AcceptAnswer` | 提问者 / 课程管理者 | E06 | QA |
| `PostComment` | 任何已登录用户 | E07 | QA |
| `CastVote` / `ChangeVote` / `WithdrawVote` | 任何已登录用户（不能投自己的内容） | E08 | QA |
| `DeleteContent` | 作者 / 课程管理者 | E09 | QA |
| `OpenBounty` | 提问者（需声誉达标） | E12 | Reputation |
| `AwardBounty` | 提问者 / 定时任务（过期自动） | E13 | Reputation |
| `CloseBounty` | 提问者 / 定时任务 | E14 | Reputation |

---

## 四、角色清单（黄色便利贴）

| 角色 | 说明 | 主要命令 |
| --- | --- | --- |
| 学生 Student | 提问、回答、投票、评论的主体 | PostQuestion / SubmitAnswer / CastVote |
| 教师 Teacher | 课程管理者，可认证回答、删除内容 | EndorseAnswer / DeleteContent |
| 助教 TA | 同教师的课程管理权限（CourseRole） | EndorseAnswer / DeleteContent |
| 学院管理员 Admin | 校园身份认证、全局管理 | VerifyCampusIdentity |
| 定时任务 Scheduled Job | 悬赏过期自动发放/关闭 | AwardBounty / CloseBounty |

---

## 五、外部系统清单（粉色便利贴）

| 外部系统 | 交互点 | 集成方式 |
| --- | --- | --- |
| 校园统一身份认证（OAuth/CAS） | `UserRegistered`、`UserVerified` | 防腐层（ACL）——不把校园身份体系的模型泄漏进 Identity 上下文 |
| 邮件服务 | 注册验证、通知外发 | 出站适配器，异步 |
| 对象存储（图片/附件上传） | 问题与回答正文中的图片 | 出站适配器，返回 URL |
| 搜索引擎（Discovery） | 全文检索索引 | 订阅集成事件构建读模型（SearchDocument） |

---

## 六、热点 Hot Spot（紫色/红色标记，现场必须挂出来讨论）

| # | 热点 | 问题 | 现场决策建议 |
| --- | --- | --- | --- |
| H1 | **悬赏过期如何发放** | 无人回答 / 多个合格回答时，过期后声誉退回还是强制发放？ | 需明确规则；建议「过期未采纳 → 若有回答则发给最高票，否则退回」 |
| H2 | **声誉能否回溯重算** | 规则调整（如某事件分值变化）后，历史账目是否重算？ | 建议只追加冲正账目（`LedgerEntry`），不改写历史 |
| H3 | **删除内容后的声誉处理** | `ContentDeleted` 是否要撤销因该内容获得的声誉？ | 建议撤销并记冲正账目 |
| H4 | **投票与声誉的时序** | `VoteCast` → `ReputationChanged` 是同步还是最终一致？ | 按 ADR-002 走事务性发件箱，**最终一致**，UI 上短暂延迟可接受 |
| H5 | **标签同义词合并** | `数据结构` / `DS` 是否算同一标签？ | 建议 v1.0 不做同义词，人工规范；避免引入额外聚合 |
| H6 | **搜索索引最终一致** | Discovery 是只读投影，索引落后多久可接受？ | 明确 SLA（如 5 秒内），写进 DoD |

---

## 七、现场执行清单

- [ ] 按 §一 铺橙色事件贴（14 张确定 + 5 张候选）
- [ ] 按 §二 在时间线上排列，补现场新发现的事件
- [ ] 每张贴下方补蓝色命令（§三）、左侧补黄色角色（§四）
- [ ] 挂粉色外部系统贴（§五）
- [ ] 挂 6 张热点贴（§六），逐个定论并记录在本文档
- [ ] **拍全景照片**（Lab 3 提交物 1）
- [ ] 圈限界上下文虚线圈 → 产出上下文映射图（提交物 2）
