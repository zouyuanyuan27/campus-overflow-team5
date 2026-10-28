Feature: 软删除问题和回答
  作为 作者或课程管理者
  我想 软删除问题和回答
  以便 清理不当内容且可追责

  Background:
    Given 小明是问题 #100 的作者
    And 问题 #100 存在

  Scenario: 快乐路径-作者删除无回答的问题
    Given 问题 #100 尚无任何回答
    And 小明已登录
    When 小明删除问题 #100
    Then 系统返回 204 No Content
    And 问题被标记删除（deleted_at 设置）
    And 列表与详情中不再出现该问题

  Scenario: 快乐路径-课程管理者删除任意问题
    Given 王老师是该课程的课程管理者
    When 王老师删除问题 #100
    Then 系统返回 204 No Content
    And 即使问题已有回答也被删除

  Scenario: 异常路径-作者删除已有回答的问题
    Given 问题 #100 已有回答，回答数为 1
    And 小明是作者
    When 小明尝试删除问题 #100
    Then 系统返回 422 QA-1013
    And 提示"已有回答的问题提问者不能删除"

  Scenario: 异常路径-路人删除他人内容
    Given 小刚既不是作者也不是课程管理者
    When 小刚尝试删除问题 #100
    Then 系统返回 403 QA-3003
    And 提示"无权删除"

  Scenario: 异常路径-被采纳回答的作者删除该回答
    Given 小红的回答 A 已被采纳（accepted=true）
    And 小红是回答 A 的作者
    When 小红尝试删除回答 A
    Then 系统返回 422 QA-1012
    And 提示"被采纳的回答不能由作者删除"

  Scenario: 快乐路径-课程管理者删除被采纳的回答
    Given 小红的回答 A 已被采纳
    And 王老师是课程管理者
    When 王老师删除回答 A
    Then 系统返回 204 No Content
    And 回答被标记删除
