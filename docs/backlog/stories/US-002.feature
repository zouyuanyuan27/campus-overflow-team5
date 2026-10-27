Feature: US-002 学生登录账号
  Scenario: 正常登录
    Given 用户拥有合法账号
    When 用户输入正确账号密码，点击登录
    Then 登录成功，进入平台主页

  Scenario: 边界场景-密码长度刚好达到最短限制
    Given 用户拥有合法账号
    When 用户输入账号和最短长度合法密码
    Then 登录成功

  Scenario: 异常场景-密码错误登录
    Given 用户拥有合法账号
    When 用户输入账号、错误密码提交登录
    Then 系统提示账号或密码错误，无法登录
