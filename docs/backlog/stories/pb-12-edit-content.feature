Feature: 编辑问题和回答
  作为 作者或课程管理者
  我想 编辑问题和回答
  以便 修正内容

  Background:
    Given 小明是问题 #100 的作者
    And 问题 #100 存在且未删除

  Scenario: 快乐路径-作者编辑自己的问题
    Given 小明已登录
    When 小明编辑问题 #100 的标题、正文和标签
    Then 系统返回 200 OK
    And 问题内容更新成功
    And 标签计数按新旧差集正确增减
    And updatedAt 被更新

  Scenario: 快乐路径-课程管理者编辑他人内容
    Given 王老师是该课程的课程管理者
    When 王老师编辑问题 #100
    Then 系统返回 200 OK
    And 问题内容更新成功

  Scenario: 异常路径-路人编辑他人内容
    Given 小刚既不是作者也不是课程管理者
    When 小刚尝试编辑问题 #100
    Then 系统返回 403 QA-3002
    And 提示"无权编辑"

  Scenario: 异常路径-编辑已删除的内容
    Given 问题 #100 已被删除
    When 小明尝试编辑问题 #100
    Then 系统返回 422 QA-1020
    And 提示"内容已删除，不能编辑"
