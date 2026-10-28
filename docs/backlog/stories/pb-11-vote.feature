Feature: 对他人问题/回答投票、改投或撤销
  作为 用户
  我想 对他人的问题或回答进行投票、改投或撤销
  以便 评价内容质量

  Background:
    Given 小刚已登录
    And 小红发布了一个回答 A，作者是小红
    And 小明发布了一个问题 Q，作者是小明

  Scenario: 快乐路径-给回答点赞
    Given 小刚进入问题详情页
    When 小刚给回答 A 点赞（+1）
    Then 回答 A 的得分变为 +1
    And 回答作者小红被记录 +10 声誉（每日上限内）

  Scenario: 快乐路径-改投
    Given 小刚已给回答 A 投 +1
    When 小刚把投票改为踩（-1）
    Then 回答 A 的得分变为 -1
    And 按差值（-1 - 1 = -2）更新小红声誉

  Scenario: 快乐路径-撤销投票
    Given 小刚已给回答 A 投 +1
    When 小刚撤销投票（value=0）
    Then 回答 A 的得分回到 0
    And 小红的声誉按差值 -1 更新

  Scenario: 边界路径-重复相同投票（幂等）
    Given 小刚已给回答 A 投 +1
    When 小刚再次投 +1
    Then 回答 A 的得分不变，仍为 +1
    And 不重复发放事件

  Scenario: 异常路径-给自己内容投票
    Given 小刚是问题 Q 的作者
    When 小刚给自己的问题 Q 点赞
    Then 系统返回 422 QA-1015
    And 提示"不能给自己的内容投票"

  Scenario: 异常路径-投票值非法
    Given 小刚提交投票值 2
    When 小刚发起投票请求
    Then 系统返回 422 QA-1014
    And 提示"投票值只能为-1、0或+1"

  Scenario: 异常路径-对已删除内容投票
    Given 回答 A 已被删除
    When 小刚尝试给回答 A 投票
    Then 系统返回 404 QA-4002
    And 提示"回答不存在或已删除"
