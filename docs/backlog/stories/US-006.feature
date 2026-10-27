Feature: 提问时上传图片
  作为登录用户，我想要在提问时上传图片，以便更好描述我的问题

  Scenario: 上传合规图片成功
    Given 我已登录且正在编辑问题
    When 我上传一张 2MB 的 PNG 图片
    Then 上传成功并返回图片访问地址
    And 图片插入至正文光标位置

  Scenario: 上传大小达到上限的图片
    Given 我已登录且正在编辑问题
    When 我上传一张大小恰为 5MB 的 JPG 图片
    Then 上传成功并返回图片访问地址

  Scenario: 上传不支持的文件类型
    Given 我已登录且正在编辑问题
    When 我上传一个 EXE 格式文件
    Then 上传失败并提示"仅支持 PNG、JPG、GIF 格式"
    And 正文内容不受影响
