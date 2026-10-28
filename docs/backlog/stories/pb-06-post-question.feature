Feature: 发布带标签、可关联课程的问题
  作为 学生
  我想 发布一个带标签、可关联课程的问题
  以便 向同学和老师求助

  Background:
    Given 小明已登录
    And 小明是 STUDENT 角色

  Scenario: 快乐路径-发布问题成功
    Given 小明进入发布问题页面
    And 小明输入标题"如何理解 Spring Boot 依赖注入"
    And 小明输入正文"我看不懂构造器注入和字段注入的区别"
    And 小明选择标签"java","spring"
    And 小明选择课程"软件工程"
    When 小明点击提交
    Then 系统返回 201 Created
    And 首页问题列表第一条显示该问题
    And 标签被规范化为小写且去重
    And 问题可关联到所选课程

  Scenario: 边界路径-标题恰好达到下限10字
    Given 小明进入发布问题页面
    And 小明输入标题"标题长度十字符测试"
    When 小明点击提交
    Then 系统返回 201 Created

  Scenario: 边界路径-标题超过上限150字
    Given 小明进入发布问题页面
    And 小明输入一个151字的长标题
    When 小明点击提交
    Then 系统返回 422 QA-1001
    And 提示"标题长度不合法"

  Scenario: 边界路径-标签超过5个
    Given 小明进入发布问题页面
    And 小明选择6个标签
    When 小明点击提交
    Then 系统返回 422 QA-1004
    And 提示"标签数量必须在1-5之间"

  Scenario: 边界路径-标签格式不合法
    Given 小明进入发布问题页面
    And 小明选择标签"#java","java!",""
    When 小明点击提交
    Then 系统返回 422 QA-1005
    And 提示"标签格式不合法"

  Scenario: 异常路径-未登录用户发布问题
    Given 小明未登录
    When 小明尝试发布问题
    Then 系统返回 401 Unauthorized
    And 跳转到登录页面

  Scenario: 异常路径-选择的课程不存在
    Given 小明已登录
    And 小明选择一个不存在的课程ID
    When 小明点击提交
    Then 系统返回 404 ID-4002
    And 提示"课程不存在"
