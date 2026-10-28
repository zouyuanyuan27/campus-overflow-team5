Feature: 采纳最佳答案
  作为 提问者或课程管理者
  我想 采纳一个最佳答案
  以便 标记问题已解决并奖励回答者

  Background:
    Given 小明是问题 #100 的提问者
    And 问题 #100 存在且未采纳
    And 小红提交了回答 A

  Scenario: 快乐路径-提问者采纳答案
    Given 小明已登录
    When 小明采纳回答 A
    Then 系统返回 204 No Content
    And 问题 #100 被标记为已采纳
    And 回答 A 被置顶显示"已采纳"
    And 回答者小红获得 +15 声誉

  Scenario: 快乐路径-课程管理者采纳答案
    Given 王老师是该课程的课程管理者
    When 王老师采纳回答 A
    Then 系统返回 204 No Content
    And 问题被标记为已采纳

  Scenario: 异常路径-非提问者非管理者采纳
    Given 小刚是普通学生，不是提问者也不是课程管理者
    When 小刚尝试采纳回答 A
    Then 系统返回 403 QA-3001
    And 提示"只有提问者或课程教师/助教可以采纳"

  Scenario: 异常路径-重复采纳
    Given 问题 #100 已被采纳过一次
    When 小明再次采纳另一个回答
    Then 系统返回 409 QA-2002
    And 提示"问题已采纳，不能重复采纳"

  Scenario: 异常路径-答案不属于该问题
    Given 回答 B 属于问题 #200，不属于问题 #100
    When 小明尝试采纳回答 B
    Then 系统返回 422 QA-1010
    And 提示"答案不属于该问题"

  Scenario: 异常路径-采纳已删除的回答
    Given 回答 A 已被删除
    When 小明尝试采纳回答 A
    Then 系统返回 422 QA-1011
    And 提示"已删除的回答不能被采纳"
