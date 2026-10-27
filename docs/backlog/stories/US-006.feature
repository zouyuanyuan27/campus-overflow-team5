Feature: US-006 发布问题时上传图片
  Scenario: 正常上传图片
    Given 用户已登录，正在发布问题
    When 选择一张大小合规图片上传并提交问题
    Then 图片随问题一起保存展示

  Scenario: 边界场景-图片大小达到上限
    Given 用户已登录
    When 选择等于最大限制大小的图片上传
    Then 图片上传成功

  Scenario: 异常场景-上传不支持的文件格式
    Given 用户已登录
    When 上传exe等不允许的文件
    Then 系统提示文件格式不支持，上传失败
