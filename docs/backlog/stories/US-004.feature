Feature: US-004 查看问题详情
  Scenario: 正常查看问题详情
    Given 平台存在一条公开问题
    When 用户点击该问题
    Then 页面展示问题描述和已有回答

  Scenario: 边界场景-问题内容很长
    Given 存在一条内容超长的公开问题
    When 用户点击打开这条问题
    Then 完整展示内容，页面正常渲染

  Scenario: 异常场景-访问已删除的问题
    Given 这条问题已经被作者删除
    When 用户访问该问题链接
    Then 页面提示问题不存在
