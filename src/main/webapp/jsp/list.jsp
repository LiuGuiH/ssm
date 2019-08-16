<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2019/8/12
  Time: 22:31
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    pageContext.setAttribute("APP_PATH", request.getContextPath());
%>
<html>
<head>
    <title>ssm-crud</title>
    <script type="text/javascript"
            src="${pageContext.request.contextPath}/static/js/jquery-3.2.1.min.js"></script>
    <link
            href="${pageContext.request.contextPath}/static/bootstrap-3.3.7-dist/css/bootstrap.min.css"
            rel="stylesheet">
    <script
            src="${pageContext.request.contextPath}/static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
</head>
<body>
<!-- 用户添加的模态框 -->
<div class="modal fade" id="userAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">用户添加</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">id</label>
                        <div class="col-sm-10">
                            <input type="text" name="id" class="form-control" id="id_add_input" placeholder="id">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">username</label>
                        <div class="col-sm-10">
                            <input type="text" name="username" class="form-control" id="username_add_input" placeholder="username">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">password</label>
                        <div class="col-sm-10">
                            <input type="text" name="password" class="form-control" id="password_add_input" placeholder="****">
                            <span class="help-block"></span>
                        </div>
                    </div>
               </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="user_save_btn">保存</button>
            </div>
        </div>
    </div>
</div>
<!-- 用户修改的模态框 -->
<div class="modal fade" id="userUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel_update">用户修改</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">id</label>
                        <div class="col-sm-10">
                            <input type="text" name="id" class="form-control" id="id_update_input" value="${user.id}" readonly="readonly">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">username</label>
                        <div class="col-sm-10">
                            <input type="text" name="username" class="form-control" id="username_update_input"  placeholder="username">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">password</label>
                        <div class="col-sm-10">
                            <input type="text" name="password" class="form-control" id="password_update_input" placeholder="****">
                            <span class="help-block"></span>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="user_saveUpdate_btn">保存</button>
            </div>
        </div>
    </div>
</div>


<!-- 搭建显示页面 -->
<div class="container">
    <!-- 标题 -->
    <div class="row">
        <div class="col-md-12">
            <h1>CRUD</h1>
        </div>
    </div>
    <!-- 按钮 -->
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="user_add_modal_btn">新增</button>
            <button class="btn btn-danger"  id="user_delete_all_btn">批量删除</button>
        </div>
    </div>
    <!-- 显示表格数据 -->
    <div class="row">
        <div class="col-md-12">
            <table class="table table-hover" id="user_table">
                <thead>
                <tr>
                    <th>
                        <input type="checkbox" id="check_all"/>
                    </th>
                    <th>#</th>
                    <th>username</th>
                    <th>password</th>
                     <th>操作</th>
                </tr>
                </thead>
                <tbody>

                </tbody>
            </table>
        </div>
    </div>
    <!-- 显示分页信息 -->
    <div class="row">
        <!--分页文字信息  -->
        <div class="col-md-6" id="page_info_area"></div>
        <!-- 分页条信息 -->
        <div class="col-md-6" id="page_nav_area">

        </div>
    </div>
</div>
<script>
    $(function(){
        to_page(1);
    });
    function to_page(pn){
        $.ajax({
            url:"${pageContext.request.contextPath}/users",
            data:"pn="+pn,
            type:"GET",
            success:function(result){
             //1、解析并显示员工数据
                build_users_table(result);
                //2、解析并显示分页信息
                build_page_info(result);
                //3、解析显示分页条数据
                build_page_nav(result);
            }
        });
    }

    function build_users_table(result){
        //清空table表格
        $("#user_table tbody").empty();
        var users = result.extend.pageInfo.list;
        $.each(users,function(index,item){
            var checkBoxTd =  $("<td></td>").append($("<input type='checkbox' class='check_item' name='check_item'/>").val(item.id));
            var userIdTd = $("<td></td>").append(item.id);
            var usernameTd = $("<td></td>").append(item.username);
            var passwordTd = $("<td></td>").append(item.password);


            var editBtn = $("<button></button>").addClass("btn btn-primary btn-sm edit_btn")
                .append($("<span></span>").addClass("glyphicon glyphicon-pencil")).append("编辑");
            //为编辑按钮添加一个自定义的属性，来表示当前员工id
            editBtn.attr("edit-id",item.id);
            var delBtn =  $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
                .append($("<span></span>").addClass("glyphicon glyphicon-trash")).append("删除");
            //为删除按钮添加一个自定义的属性来表示当前删除的员工id
            delBtn.attr("del-id",item.id);
            var btnTd = $("<td></td>").append(editBtn).append(" ").append(delBtn);
            //var delBtn =
            //append方法执行完成以后还是返回原来的元素
            $("<tr></tr>").append(checkBoxTd)
                .append(userIdTd)
                .append(usernameTd)
                .append(passwordTd)
                .append(btnTd)
                .appendTo("#user_table tbody");
        });
    }

    function build_page_info(result) {
        $("#page_info_area").empty();
        $("#page_info_area").append("当前"+result.extend.pageInfo.pageNum+"页,总"+
            result.extend.pageInfo.pages+"页,总"+
            result.extend.pageInfo.total+"条记录");
        totalRecord = result.extend.pageInfo.total;//最后的数据
        currentPage = result.extend.pageInfo.pageNum;//当前页
    }
    function build_page_nav(result) {
        //page_nav_area
        $("#page_nav_area").empty();
        var ul = $("<ul></ul>").addClass("pagination");

        //构建元素
        var firstPageLi = $("<li></li>").append($("<a></a>").append("首页").attr("href","#"));
        var prePageLi = $("<li></li>").append($("<a></a>").append("&laquo;"));
        if(result.extend.pageInfo.hasPreviousPage == false){
            firstPageLi.addClass("disabled");
            prePageLi.addClass("disabled");
        }else{
            //为元素添加点击翻页的事件
            firstPageLi.click(function(){
                to_page(1);
            });
            prePageLi.click(function(){
                to_page(result.extend.pageInfo.pageNum -1);
            });
        }

        var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));
        var lastPageLi = $("<li></li>").append($("<a></a>").append("末页").attr("href","#"));
        if(result.extend.pageInfo.hasNextPage == false){
            nextPageLi.addClass("disabled");
            lastPageLi.addClass("disabled");
        }else{
            nextPageLi.click(function(){
                to_page(result.extend.pageInfo.pageNum +1);
            });
            lastPageLi.click(function(){
                to_page(result.extend.pageInfo.pages);
            });
        }

        //添加首页和前一页 的提示
        ul.append(firstPageLi).append(prePageLi);
        //1,2，3遍历给ul中添加页码提示
        $.each(result.extend.pageInfo.navigatepageNums,function(index,item){

            var numLi = $("<li></li>").append($("<a></a>").append(item));
            if(result.extend.pageInfo.pageNum == item){
                numLi.addClass("active");
            }
            numLi.click(function(){
                to_page(item);
            });
            ul.append(numLi);
        });
        //添加下一页和末页 的提示
        ul.append(nextPageLi).append(lastPageLi);

        //把ul加入到nav
        var navEle = $("<nav></nav>").append(ul);
        navEle.appendTo("#page_nav_area");
    }

    //清空表单样式及内容
    function reset_form(ele){
        $(ele)[0].reset();
        //清空表单样式
        $(ele).find("*").removeClass("has-error has-success");
        $(ele).find(".help-block").text("");
    }
    //点击新增按钮弹出模态框。
    $("#user_add_modal_btn").click(function(){
        //清除表单数据（表单完整重置（表单的数据，表单的样式））
        reset_form("#userAddModal form");
        //弹出模态框
        $("#userAddModal").modal({
            backdrop:"static"
        });
    });
    //点击保存，保存员工。
    $("#user_save_btn").click(function(){
        //2、发送ajax请求保存员工
        $.ajax({
            url:"${APP_PATH}/add",
            type:"POST",
            data:$("#userAddModal form").serialize(),
            success:function(result){
                //alert(result.msg);
                if(result.code == 100){
                    //员工保存成功；
                    //1、关闭模态框
                    $("#userAddModal").modal('hide');

                    //2、显示刚才保存的数据
                    to_page(totalRecord);
                }else{
                    //显示失败信息
                    console.log(result);
                }
            }
        });
    });

    //单个删除
    $(document).on("click",".delete_btn",function(){
        //1、弹出是否确认删除对话框
        var empName = $(this).parents("tr").find("td:eq(2)").text();
        var userId = $(this).attr("del-id");

        if(confirm("确认删除【"+empName+"】吗？")){
            //确认，发送ajax请求删除即可
            $.ajax({
                url:"${APP_PATH}/delete?id="+userId,
                type:"GET",
                success:function(result){
                    alert(result.msg);
                    //回到本页
                    to_page(1);
                }
            });
        }
    });
    //修改
    $(document).on("click",".edit_btn",function () {
        var userId = $(this).attr("edit-id");
        //清除表单数据（表单完整重置（表单的数据，表单的样式））
        reset_form("#userUpdateModal form");
        $.ajax({
            url:"${APP_PATH}/edit?id="+userId,
            type:"GET",
            success:function (result) {
                console.log(result.msg);
                $("#id_update_input").val(result.extend.user.id);
            }
        });

        //弹出模态框
        $("#userUpdateModal").modal({
            backdrop:"static"
        });
    });
    //点击保存修改，保存员工。
    $("#user_saveUpdate_btn").click(function(){
        //2、发送ajax请求保存员工
        $.ajax({
            url:"${APP_PATH}/update",
            type:"POST",
            data:$("#userUpdateModal form").serialize(),
            success:function(result){
                //alert(result.msg);
                if(result.code == 100){
                    //员工保存成功；
                    //1、关闭模态框
                    $("#userUpdateModal").modal('hide');

                    //2、显示刚才保存的数据
                    to_page(1);
                }else{
                    //显示失败信息
                    console.log(result);
                }
            }
        });
    });


    $("#user_delete_all_btn").click(function () {
        var obj = document.getElementsByName("check_item");
        var checkId_val = [];
        for(var k in obj){
            if(obj[k].checked)
                checkId_val.push(obj[k].value);

        }
        $.ajax({
            url:"${APP_PATH}/deleteAll?checkId_val="+checkId_val,
            type:"GET",
            success:function(result){
                if(result.code == 100){
                    alert(result.msg);
                    to_page(currentPage);
                }else{
                    console.log(result.msg);
                }
            }
        })
    })

</script>
</body>
</html>