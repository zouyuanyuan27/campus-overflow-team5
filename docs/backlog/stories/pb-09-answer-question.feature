Feature: 回答未删除的问题
  作为 学生
  我想 回答一个未删除的问题
  以便 帮助提问者解决问题

  Background:
    Given 小红已登录
    And 问题 #100 存在且未删除

  Scenario: 快乐路径-提交回答成功
    Given 小红进入问题 #100 详情页
    And 小红输入回答正文"这是一个可行的解决方案..."
    When 小红点击提交回答
    Then 系统返回 201 Created
    And 问题回答数 +1
    And 详情页显示小红的新回答（Markdown 已渲染且净化）
    And 提问者收到"有新回答"的通知

  Scenario: 边界路径-回答正文达到上限
    Given 小红输入一个正好 30000 字的回答正文
    When 小红提交回答
    Then 系统返回 201 Created

  Scenario: 边界路径-回答正文超过上限
    Given 小红输入一个超过 30000 字的回答正文
    When 小红提交回答
    Then 系统返回 422 QA-1002
    And 提示"回答正文长度不合法"

  Scenario: 异常路径-回答已删除的问题
    Given 问题 #100 已被删除
    When 小红尝试回答该问题
    Then 系统返回 422 QA-1020
    And 提示"内容已删除，不能回答"

  Scenario: 异常路径-未登录用户回答
    Given 小红未登录
    When 小红尝试回答问题 #100
    Then 系统返回 401 Unauthorized
