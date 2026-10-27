# PR #10 评审记录 · 李增艳（SM）自我介绍

> 评审人：张嘉雨（@ember216），角色 **Developer**
> 被评审 PR：#10　｜　作者：李增艳（SM @LZY901-art）
> 分支：`feature/LZY-hello`　｜　提交：`973157b`
> 改动：`docs/team/hello-LZY.md`（新增，6 行纯文本）
> 评审时间：2026-10-27　｜　**结论：Request changes（4 必改 + 4 建议）**
> 归档用途：**Lab 7 提交物 2 —— 至少 4 份高质量 PR 评审记录**（本份为第 4 份：#5 → #11 → #13 → #10）

---

## 一、对照基准

main 上已合并的两份（王钰滢 `hello-wangyuying.md`、我 `hello-zhangjiayu.md`）确立了统一口径：

| 要求 | 基准 | PR #10 |
| --- | --- | --- |
| 文件数 | **3 份**（hello / role-commitment / skill-matrix） | **1 份** ❌ |
| 文件名 | 全拼小写：`hello-wangyuying.md` | `hello-LZY.md` ❌（缩写） |
| 结构 | `#` 标题 + `##` 小节 | 裸文本，无标题层级 ❌ |
| 必填字段 | 姓名 / 学号处理说明 / 班级·小组 / GitHub / 角色 | 只有姓名、专业、角色 ❌ |

---

## 二、必改（M）

**M1 · 缺 2 份交付物。** 只有 hello，缺 `docs/team/role-commitment-lizengyan.md` 与 `docs/team/skill-matrix-lizengyan.md`。
PR #5（秦悦）三轮评审确立的就是三件套口径，main 上王钰滢已是完整 3 份 —— 不能她 3 份、别人 1 份。

**M2 · 文件名不符全拼约定。** `hello-LZY.md` → `hello-lizengyan.md`。
main 上所有文件均为全拼（`hello-wangyuying` / `hello-zhangjiayu` / `role-commitment-*`）。缩写会让后面按名字检索文档的人找不到。

**M3 · 无 Markdown 结构。** 首行是裸文本「大家好，我是李增艳…」，没有 `#` 标题和 `##` 小节。
仓库里所有 `docs/team/` 文档都是结构化 Markdown，这份混进去会破坏一致性。

**M4 · 缺必填字段。** 差 3 项：
- **GitHub 用户名** `@LZY901-art`（团队表已登记，公共仓库应公开标识，便于 PR 归属）
- **班级 / 小组**：计科2412班 · 第 5 组
- **学号处理说明**：参照已合并版本写「已登记于纸质承诺书，Public 仓库不录入」——**Public 仓库禁止出现学号**

---

## 三、建议（S）

**S1 · SM 角色承诺要写具体。** 你现在写了"维护看板、把关 PR、控制范围"，建议补上可验收的口径，后续章程也好对齐：
看板更新频率（如每日站会后）、PR 响应时限（如 24h 内首次回应）、合并策略（squash and merge）、Sprint 范围冻结规则。

**S2 · 补「希望在这个项目中学到什么」。** 已合并的两份都有这一节，是团队互相了解的主要入口。

**S3 · commit message 缺签名。** `973157b` 是 `feat(team): 添加李增艳的自我介绍`，无 `Signed-off-by`。
**这是实验手册的硬要求**（同 PR #11 的 M2），建议补：

```
Signed-off-by: LZY901-art <你的邮箱>
```

**S4 · 技术栈自评放到 skill-matrix。** hello 里不用展开，按「会 / 学过但不熟 / 没接触过」三档写进技能矩阵，方便 PO 排活 —— 你是 SM，测试和 CI 那块大家会依赖你，写清楚能减少后续返工。

---

## 四、可直接粘贴的 Review 正文

```markdown
@LZY901-art 欢迎加入！内容读得出你对 SM 职责很清楚，不过有 4 条要改完才能合并：

**M1 缺 2 份交付物**——只有 hello，还缺 `docs/team/role-commitment-lizengyan.md` 和 `docs/team/skill-matrix-lizengyan.md`。PR #5 三轮评审确立的就是三件套口径，main 上王钰滢已经是完整 3 份了，不能她 3 份、其他人 1 份。

**M2 文件名改全拼**——`hello-LZY.md` → `hello-lizengyan.md`。main 上都是全拼（hello-wangyuying / hello-zhangjiayu），缩写后面按名字检索会找不到。

**M3 要有 Markdown 结构**——现在首行是裸文本，缺 `#` 标题和 `##` 小节。可以照 main 上已合并的 `hello-wangyuying.md` 的格式来写。

**M4 补 3 个必填字段**——GitHub 用户名 `@LZY901-art`、班级小组「计科2412班 · 第 5 组」、学号处理说明（写成"已登记于纸质承诺书，Public 仓库不录入"就行，**学号本身绝对不能进 Public 仓库**）。

另有 4 条建议：

- **S1** SM 的承诺可以写得更能验收：看板更新频率、PR 响应时限（比如 24h 内首次回应）、合并策略（squash）、Sprint 范围冻结规则。写进 role-commitment 后章程也好对齐。
- **S2** 补一节「希望在这个项目中学到什么」，已合并的两份都有。
- **S3** commit message 要加 `Signed-off-by`，这是实验手册的硬要求（和 PR #11 里提的一样）。
- **S4** 技术栈自评按「会 / 学过但不熟 / 没接触过」三档写进 skill-matrix，你是 SM，测试和 CI 那块大家会依赖你，写清楚能少返工。

需要我帮你起个 role-commitment 的骨架吗？
```

---

## 五、建议她直接用的文件骨架

`docs/team/hello-lizengyan.md`

```markdown
# 自我介绍 · 李增艳

## 基本信息

- **姓名**：李增艳
- **学号**：已登记于纸质承诺书（Public 仓库不录入学号，需核对时找 SM 或查纸质版）
- **班级 / 小组**：计科2412班 · 第 5 组
- **GitHub**：@LZY901-art
- **团队角色**：SM（Scrum Master）

## 作为 SM 我负责什么

- 维护看板与燃尽图，每日站会后更新
- 把关 PR 评审与合并（squash and merge），24h 内首次回应
- 控制 Sprint 范围，范围冻结后新增需 PO 同意
- 协调环境与 CI 问题

## 目前会什么

（按「会 / 学过但不熟 / 没接触过」三档写）

## 我希望在这个项目中学到什么

1. …
2. …
```

---

## 六、评审统计

| 项 | 数量 |
| --- | --- |
| 必改（M） | 4 |
| 建议（S） | 4 |
| **实质意见合计** | **8**（≥5 ✅） |
| 给出具体改法或模板的 | 8 / 8 |
| 引用手册 / 团队既有约定的 | M1、M2、M3、M4、S3（5 条） |
