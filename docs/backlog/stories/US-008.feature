Feature: US-008 登录用户提交回答
Scenario: 正常提交回答
Given 用户已登录，打开一个问题
When 用户填写回答内容提交
Then 回答成功发布在问题下方
# 【快乐路径】

Scenario: 边界场景-回答内容刚好最短长度
Given 用户已登录
When 输入达到最低字数的回答提交
Then 回答发布成功
# 【边界路径】

Scenario: 异常场景-回答已关闭的问题
Given 该问题已经关闭，不接受新回答
When 用户填写回答提交
Then 系统提示该问题不能新增回答
# 【异常路径】
