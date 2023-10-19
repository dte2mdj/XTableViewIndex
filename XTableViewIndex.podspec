#
# Be sure to run `pod lib lint XTableViewIndex.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'XTableViewIndex'
    s.version          = '0.0.4'
    s.summary          = '用于替代系统私有的UITableViewIndex'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
    1、选中时预览放大
    2、滑动时触感反馈
    3、颜色随意设置
    4、字体大小设置
    5、支持全局初始配置
    DESC

    s.homepage         = 'https://github.com/dte2mdj/XTableViewIndex'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Xwg' => 'awen365@qq.com' }
    s.source           = { :git => 'https://github.com/dte2mdj/XTableViewIndex.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.swift_version = '5.0'

    s.ios.deployment_target = '9.0'

    s.source_files = 'XTableViewIndex/Classes/**/*'

    s.resource_bundles = {
        'XTableViewIndex' => ['XTableViewIndex/Assets/*.png']
    }

    # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
