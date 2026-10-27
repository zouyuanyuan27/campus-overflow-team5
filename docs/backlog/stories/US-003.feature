Feature: US-003 访客浏览问题列表
Scenario: 正常浏览问题列表
Given 用户是访客，未登录
When 用户进入问题列表页面
Then 页面加载展示全部公开问题列表
# 【快乐路径】

Scenario: 边界场景-问题列表为空
Given 平台暂时没有发布任何问题
When 访客打开问题列表页面
Then 页面提示暂无问题
# 【边界路径】

Scenario: 异常场景-网络中断加载列表
Given 用户是访客
When 打开问题列表时网络断开
Then 页面提示网络异常，加载失败
# 【异常路径】
