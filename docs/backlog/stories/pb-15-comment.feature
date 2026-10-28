Feature: 评论问题或回答并进行一层回复
  作为 用户
  我想 评论问题或回答并进行一层回复
  以便 追问与澄清

  Background:
    Given 小明已登录
    And 问题 #100 存在
    And 回答 A 挂在问题 #100 下

  Scenario: 快乐路径-评论问题
    Given 小明进入问题 #100 详情页
    When 小明对问题 #100 发表评论
    Then 系统返回 201 Created
    And 评论显示在问题下

  Scenario: 快乐路径-评论回答
    Given 小明进入问题 #100 详情页
    When 小明对回答 A 发表评论
    Then 系统返回 201 Created
    And 评论显示在回答下

  Scenario: 快乐路径-对顶层评论进行一层回复
    Given 小红在回答 A 下有一条顶层评论 C1
    When 小明回复评论 C1
    Then 系统返回 201 Created
    And 回复挂在评论 C1 下

  Scenario: 边界路径-评论正文长度下限
    Given 小明输入 2 个字符的评论正文
    When 小明发表评论
    Then 系统返回 201 Created

  Scenario: 边界路径-评论正文超过600字
    Given 小明输入 601 个字符的评论正文
    When 小明发表评论
    Then 系统返回 422 QA-1003
    And 提示"评论长度不合法"

  Scenario: 异常路径-回复层数超限（两层回复）
    Given 存在评论 C1
    And 评论 C2 是对 C1 的回复（一层）
    When 小明尝试回复评论 C2
    Then 系统返回 422 QA-1016
    And 提示"回复只允许一层"

  Scenario: 异常路径-回复与父评论不同目标
    Given 评论 C1 挂在回答 A 下
    When 小明在问题 #100 下回复评论 C1
    Then 系统返回 422 QA-1017
    And 提示"回复必须与父评论在同一目标上"

  Scenario: 异常路径-评论不存在的目标
    Given 回答 B 已被删除或不存在
    When 小明尝试评论回答 B
    Then 系统返回 404 QA-4002
    And 提示"回答不存在或已删除"
