# PLPlayerPackaging
###基于七牛播放器PLPlayer的二次封装（有全屏弹幕）
简单一句话实现播放功能
描述了PLPlayer的各种问题
---
title: 基于七牛播放器PLPlayer的二次封装(全屏) 以及七牛iOS播放器各个版本的问题
date: 2017-09-01
categories: "iOS"
tags:
- Objective-C
  description: 简单一句话实现播放功能。
---

**效果展示:**
![](https://raw.githubusercontent.com/enamor/ScreenImage/master/PLPlayerPackaging/show.gif)

*基于PLPlayer封装的视频播放器  目前用的是2.4.3版本、一句话即可实现视频的播放 支持横屏、竖屏，监听屏幕旋转*

**蛋疼的问题：**

* 2.3 频繁切换播放有崩溃问题 频繁切换无法播放同2.4.3解决方式
* 2.4.3  pause回调状态不对  频繁切换播放无法播放需要以下处理(

if([[UIDevice currentDevice] systemVersion].intValue>=10){

​        // 增加下面这行可以解决iOS10兼容性问题了

​        self.player.avplayer.automaticallyWaitsToMinimizeStalling = NO;

​    }

*  3.0.0 frame设置无效 首次播放之后 修改frame无效 部分视频无法播放声音

* 3.0.1  1.部分视频无法播放声音 pause 后  2.播放器 stop 再play 播放器重新绘制layer 从头播放

  **------------------------我也是醉了反正是没有完善的的版本，建议用ijkplayer替换 (如果不是老项目中用到的！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！)————————————**



**使用说明：**

*播放器需要传入一view 自动适应view的尺寸 为了简化全屏模式统一使用屏幕旋转的方式进行适配全屏、目前控制层UI未做详细拆分，后期将逐步优化、只为做最简单的视频播放器*

* 单利模式

~~~objective-c
//自动创建单例 此次一句话即可实现播放 同时适配横竖屏
[PackPlayer playWithUrl:url onView:_playView];

//单例需要手动释放
[NIPlayer releasePlayer];
~~~


*状态栏旋转需要控制器中重写方法 (目前UIViewController分类中已经重写)且需要在info.Plist 添加 View controller-based status bar appearance 设置成No，默认为Yes*

~~~objective-c

- (BOOL)shouldAutorotate {
    return NO;
}
~~~




**温馨提示:**

1、为了处理视频全屏模式后台进入前台可以平滑的进入（无启动页）对AppDelegate 添加了分类处理 重写了以下方法

~~~objective-c
//一般状态此处用户无需处理
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.allowRotationType == AllowRotationMaskPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else if (self.allowRotationType == AllowRotationMaskAllButUpsideDown) {
        return  UIInterfaceOrientationMaskAllButUpsideDown;
    }else {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
}
~~~

2、APP支持方向设置为竖屏即可

**博客地址：http://oxy.pub**