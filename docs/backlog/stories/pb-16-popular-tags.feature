Feature: 查看热门标签
  作为 用户
  我想 看到热门标签
  以便 按主题浏览问题

  Scenario: 快乐路径-查看热门标签
    Given 系统存在多个问题，标签被高频使用
    When 我请求热门标签列表
    Then 系统返回 200 OK
    And 返回按使用量排序的热门标签
    And 每个标签附带对应的问题数量

  Scenario: 快乐路径-标签使用量实时更新
    Given 小明新发布一个带标签"spring"的问题
    When 我再次请求热门标签
    Then "spring" 标签的使用量 +1

  Scenario: 边界路径-热门标签数量上限
    Given 系统存在超过 50 个标签
    When 我请求热门标签且 limit=50
    Then 返回 50 个热门标签

  Scenario: 边界路径-limit参数非法
    Given 我请求热门标签且 limit=0 或 limit=100
    When 提交请求
    Then 系统返回 422 校验错误
    And 提示"limit 必须在 1-50 之间"

  Scenario: 边界路径-无标签数据的空系统
    Given 系统还没有任何问题
    When 我请求热门标签
    Then 系统返回 200 OK
    And 返回空列表

  Scenario: 快乐路径-标签规范化去重
    Given 问题使用了标签"Java","java","Spring-Boot"
    When 查看热门标签
    Then 标签显示为小写且去重：java、spring-boot
