package controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import pojo.Msg;
import pojo.User;
import service.UserService;

import javax.servlet.http.HttpServletRequest;
import java.util.List;


@Controller
public class UserController {

    @Autowired
    private UserService userService;
    @RequestMapping("/users")
    @ResponseBody
    public Msg getAllusers(@RequestParam(value = "pn",defaultValue = "1") Integer pn){
        PageHelper.startPage(pn,2);
        List<User> users=userService.selectAll();
        PageInfo pageInfo=new PageInfo(users,3);
        return  Msg.success().add("pageInfo", pageInfo);
    }

    @RequestMapping("/add")
    @ResponseBody
    public Msg addUser(User user){
        userService.insert(user);
        return Msg.success();
    }


    /**
     * 如果是启动项目，则转发到list请求
     * 如果是项目，默认到首页的请求
     * @return
     */
    @RequestMapping("/")
    public String index(){
        return "list";
    }

    //响应页面的删除
    @RequestMapping("delete")
    @ResponseBody
    public Msg deleteUserById(Integer id) {
        //return userService.deleteUserById(id)>0?"ok":"error";
         userService.deleteByPrimaryKey(id);
         return Msg.success();

    }

    @RequestMapping("deleteAll")
    @ResponseBody
    public Msg deleteAll(HttpServletRequest request) {
        String checkId_val=request.getParameter("checkId_val");
        System.out.println(checkId_val);
        String id[]=checkId_val.split(",");
        System.out.println(id.toString());
        int []ids=new int[id.length];
        for (int i=0;i<id.length;i++){
            int a=Integer.parseInt(id[i]);
            ids[i]=a;
        }

        if (ids != null) {
            for(Integer id1:ids){
                userService.deleteByPrimaryKey(id1);
            }
            return Msg.success();
        }else {
            return Msg.fail();
        }

    }

    //响应页面点击修改的
    @RequestMapping("/edit")
    @ResponseBody
    public Msg getUserById(Integer id,Model model) {
        User user=userService.selectByPrimaryKey(id);
        if (user!=null){
            return Msg.success().add("user",user);
        }else {
            return Msg.fail();
        }

    }

    //点击页面的保存修改
    @RequestMapping("/update")
    @ResponseBody
    public Msg updateUser(@ModelAttribute User user) {
        if (userService.updateByPrimaryKey(user)>0){
            return Msg.success();
        }else {
            return Msg.fail();
        }

    }
}
