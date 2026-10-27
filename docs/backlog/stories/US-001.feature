Feature: US-001 学生注册账号
  Scenario: 正常注册账号
    Given 用户是未注册的学生
    When 用户填写合法账号信息，提交注册
    Then 账号注册成功，可以登录平台

  Scenario: 边界场景-用户名超长
    Given 用户是未注册的学生
    When 用户填写超过长度限制的用户名，提交注册
    Then 系统提示用户名过长，注册失败

  Scenario: 异常场景-重复用户名注册
    Given 平台已存在该用户名
    When 用户使用这个已存在的用户名提交注册
    Then 系统提示用户名已被占用，注册失败
