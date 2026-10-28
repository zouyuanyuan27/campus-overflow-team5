# Lab 3 · 读模型识别清单（L3-09）

> 负责：张嘉雨（`@ember216`）　|　日期：2026-10-28　|　状态：v1.0 底稿，待 Lab 3 现场校准
> 手册 Lab 3 Step 3 任务 9：「识别需要的读模型(Read Model)」
> 依据：`backend/co-discovery/**/domain/**`（Notification、SearchDocument、SearchIndex、RelatedQuestionPolicy、MentionParser）+ ADR-001（Discovery 是只读投影、第一拆分候选）

---

## 一、判定标准：什么时候需要读模型

满足以下任一条件才建读模型，否则直接查聚合（避免过度设计）：

1. **查询形状与聚合形状不匹配**——列表页要跨聚合聚合统计，聚合模型给不出来；
2. **查询会打穿上下文边界**——需要别的上下文的数据（跨前缀 JOIN 被 ADR-001 禁止）；
3. **查询频率远高于写入，且可容忍最终一致**——读多写少，投影后查询不再压垮写侧。

---

## 二、本项目需要的读模型（3 个）

### RM-1 · 搜索文档 `SearchDocument`

| 项 | 内容 |
| --- | --- |
| 服务的问题 | 「搜索含某关键词、某标签的问题，按时间/分数排序」——Question 聚合只有单题视图，且全文检索不能靠 SQL LIKE 扫表 |
| 数据来源 | 订阅 QA 上下文事件：`QuestionPosted`、`QuestionEdited`、`ContentDeleted` |
| 结构 | `SearchDocument`（questionId、标题、正文纯文本、标签、分数快照、时间）+ `SearchHit`、`SearchQuery`、`SearchSort` |
| 更新策略 | 事件驱动增量更新；**可整库重建**（事件重放），所以允许索引丢失后自愈 |
| 一致性 | 最终一致，SLA 建议 ≤5 秒（热点 H6，写进 DoD） |
| 代码位置 | `co-discovery-domain/.../search/`（SearchIndex 为端口，具体实现是基础设施层可替换的） |

### RM-2 · 通知 `Notification`

| 项 | 内容 |
| --- | --- |
| 服务的问题 | 「我的未读通知列表」——通知的触发方分散在三个上下文（被回答、被采纳、被@、徽章、悬赏），不可能让用户查询时横跨 qa_/rep_ 前缀 |
| 数据来源 | 订阅事件：`AnswerSubmitted`（问题作者）、`AnswerAccepted`（回答作者）、`CommentPosted`（被回复者）、`ReputationChanged` / `BadgeAwarded` / `BountyAwarded`（当事用户）；`MentionParser` 额外从正文解析 `@昵称` 生成提及通知 |
| 结构 | `Notification`（收件人、`NotificationType`、关联内容 id、已读状态、时间） |
| 更新策略 | 只增不改（已读状态除外）；通知**不回写业务**，避免事件回环 |
| 一致性 | 最终一致；用户对几秒延迟无感 |
| 代码位置 | `co-discovery-domain/.../notification/` |

### RM-3 · 相关问题推荐 `RelatedQuestion`（读模型策略，非存储）

| 项 | 内容 |
| --- | --- |
| 服务的问题 | 问题详情页右侧「相关问题」——需要同标签、同课程的问题集合，属于跨聚合查询 |
| 数据来源 | 复用 RM-1 的 `SearchDocument`（按标签过滤），叠加 `RelatedQuestionPolicy` 打分 |
| 结构 | `RelatedQuestionView`（纯视图对象，无独立存储） |
| 更新策略 | 查询时实时从 RM-1 计算，不单独投影 |
| 代码位置 | `co-discovery-domain/.../search/RelatedQuestionPolicy.java` |

---

## 三、明确**不建**读模型的查询（现场答辩用）

| 查询 | 为什么不需要 |
| --- | --- |
| 问题详情页（含回答、评论） | 聚合自身就能给，读写比不高，直接查 `qa_` 表 |
| 我的声誉页 | `ReputationAccount` + `LedgerEntry` 就是账本形态，天然适合查 |
| 课程成员列表 | `Course` 聚合内聚了成员，单聚合可查 |
| 管理端统计 | Sprint 1 不做；将来做也是新的投影，不影响现在的决定 |

> 答辩要点：读模型不是「加缓存」，而是**按查询形状重新组织数据**；每个读模型必须能回答「由哪些事件投影、丢了怎么重建、延迟多少可接受」三个问题。

---

## 四、现场待确认

- [ ] RM-1 是否需要把「回答数 / 采纳状态」也投影进文档（影响排序质量 vs 投影复杂度）
- [ ] 通知是否需要保留 30 天以上的历史（影响存储与清理策略）
- [ ] 相关问题是否纳入 Sprint 1 范围（US-009 之外的新故事）
