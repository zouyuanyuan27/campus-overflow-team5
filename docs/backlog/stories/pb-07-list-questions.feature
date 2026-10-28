Feature: 分页浏览（按课程筛选）问题列表
  作为 用户
  我想 按课程分页浏览问题列表
  以便 发现待解决的问题

  Background:
    Given 系统已存在 10 个问题，分布在不同课程下

  Scenario: 快乐路径-分页浏览问题列表
    Given 我是访客
    When 我请求第 1 页问题列表，每页 5 条
    Then 系统返回 200 OK
    And 列表包含 5 条问题摘要
    And 返回 total=10，page=1，size=5
    And 每条摘要包含标题与已采纳状态

  Scenario: 快乐路径-按课程筛选
    Given 我是访客
    And 课程"软件工程"下存在 3 个问题
    When 我按课程"软件工程"筛选并浏览第 1 页
    Then 列表只返回该课程的 3 条问题

  Scenario: 边界路径-请求最后一页
    Given 系统共 10 个问题
    When 我请求第 2 页问题列表，每页 5 条
    Then 返回剩余 5 条问题
    And 无更多分页数据

  Scenario: 边界路径-页码越界
    Given 系统共 10 个问题
    When 我请求第 99 页问题列表
    Then 返回 200 OK
    And 列表为空 items=[]，total=10

  Scenario: 边界路径-分页参数非法
    Given 我请求 page=0 或 size=0
    When 提交请求
    Then 系统返回 422 校验错误
    And 提示分页参数必须为正整数

  Scenario: 异常路径-按不存在课程筛选
    Given 我按一个不存在的课程ID筛选
    When 提交请求
    Then 系统返回 404
    And 提示"课程不存在"
