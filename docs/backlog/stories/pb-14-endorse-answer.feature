Feature: 课程教师/助教为优质回答做教师认证
  作为 课程教师/助教
  我想 为优质回答打上"教师认证"标记
  以便 给学生权威指引

  Background:
    Given 王老师是该课程的课程教师
    And 小红提交了一个回答 A

  Scenario: 快乐路径-教师认证优质回答
    Given 王老师已登录
    When 王老师认证回答 A
    Then 系统返回 204 No Content
    And 回答 A 显示"教师认证"标记（endorsedBy=王老师）
    And 回答作者小红被授予"名师认可"徽章

  Scenario: 快乐路径-助教认证回答
    Given 李助教是该课程的助教
    When 李助教认证回答 A
    Then 系统返回 204 No Content
    And 回答 A 显示教师认证标记

  Scenario: 异常路径-普通学生认证回答
    Given 小刚是普通学生，不是教师/助教
    When 小刚尝试认证回答 A
    Then 系统返回 403 QA-3004
    And 提示"无权认证"

  Scenario: 异常路径-重复认证同一回答
    Given 回答 A 已被王老师认证过一次
    When 王老师再次认证回答 A
    Then 系统返回 409 QA-2003
    And 提示"该回答已被教师认证"

  Scenario: 异常路径-认证已删除的回答
    Given 回答 A 已被删除
    When 王老师尝试认证回答 A
    Then 系统返回 422 QA-1020
    And 提示"内容已删除，不能认证"
