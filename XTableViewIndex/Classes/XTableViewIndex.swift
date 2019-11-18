//
//  XTableViewIndex.swift
//  XTableViewIndex
//
//  Created by Xwg on 2019/11/11.
//  Copyright © 2019 Xwg. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol XTableViewIndexDataSource: NSObjectProtocol {
    /// 组标题
    /// - Parameter tableViewIndex: XTableViewIndex
    @objc func indexTitles(for tableViewIndex: XTableViewIndex) -> [String]
}

@objc public protocol XTableViewIndexDelegate: NSObjectProtocol {
    /// 选中了索引用 index 的 item
    /// - Parameters:
    ///   - tableViewIndex: XTableViewIndex
    ///   - index: 索引
    @objc func tableViewIndex(_ tableViewIndex: XTableViewIndex, didSelectItemAt index: Int)
}


final public class XTableViewIndex: UIView {
    /// item 的宽度
    public static var itemWidth: CGFloat = 13.0
    
    /// item 默认颜色（默认：#44557D）
    public static var itemColor: UIColor = #colorLiteral(red: 0.2666666667, green: 0.3333333333, blue: 0.4901960784, alpha: 1)
    /// item 选中颜色（默认：.white）
    public static var itemSelectedColor: UIColor = .white
    
    /// item 默认背景色（默认：.clear）
    public static var itemBackgroundColor: UIColor = .clear
    /// item 选中背景色（默认：#FF7721）
    public static var itemSelectedBackgroundColor: UIColor = #colorLiteral(red: 1, green: 0.4666666667, blue: 0.1294117647, alpha: 1)
    
    /// item 的宽度
    public var itemWidth = XTableViewIndex.itemWidth {
        didSet {
            guard oldValue != itemWidth else { return }
            _setNeedUpdateItemsWidth()
        }
    }
    
    /// item 默认颜色（默认：#44557D）
    public var itemColor = XTableViewIndex.itemColor {
        didSet {
            guard oldValue != itemColor else { return }
            _setNeedUpdateItemsColor()
        }
    }
    /// item 选中颜色（默认：.white）
    public var itemSelectedColor = XTableViewIndex.itemSelectedColor {
           didSet {
               guard oldValue != itemSelectedColor else { return }
               _setNeedUpdateItemsColor()
           }
       }
    
    /// item 默认背景色（默认：.clear）
    public var itemBackgroundColor = XTableViewIndex.itemBackgroundColor {
           didSet {
               guard oldValue != itemBackgroundColor else { return }
               _setNeedUpdateItemsColor()
           }
       }
    /// item 选中背景色（默认：#FF7721）
    public var itemSelectedBackgroundColor = XTableViewIndex.itemSelectedBackgroundColor {
           didSet {
               guard oldValue != itemSelectedBackgroundColor else { return }
               _setNeedUpdateItemsColor()
           }
       }
    
    /// 数据源
    weak public var dataSource: XTableViewIndexDataSource? {
        didSet { reloadData() }
    }
    /// 代理
    weak public var delegate: XTableViewIndexDelegate?
    
    /// 是否在按压状态
    private(set) var isOnTouch = false
    
    /// 所有 items
    private var items: [UILabel] { contentStackView.arrangedSubviews as! [UILabel] }
    
    /// 保存选中的 item
    private var selectedItem: UILabel?
    
    /// item 的宽度约束
    private var itemWidthConstraint: NSLayoutConstraint?
    /// 预览 item 的 centerY 约束
    private var previewItemCenterYConstraint: NSLayoutConstraint?
    
    /// 存放 item 的 stackView
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    /// 预览 item
    private lazy var previewItem: UIButton = {
        
        let btn = UIButton()
        btn.setBackgroundImage(_getBundleImage(named: "preview_bg", ofType: "png"), for: .normal)
        btn.isUserInteractionEnabled = false
        btn.alpha = 0
        return btn
    }()
    
    init() {
        super.init(frame: .zero)
        _initSetupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _initSetupSubviews()
    }
    
    /// 刷新数据
    public func reloadData() {
        _addItemsToContentStackView()
    }
    
    /// 选中的 item
    /// - Parameter index: 索引
    public func selectItem(at index: Int) {
        guard index >= 0 && index < items.count - 1 && index != selectedItem?.tag else { return }
        _setSelectedItem(items[index], needFeedback: false, needExecDelegate: false)
    }
    
    /// 更新选中的 item; 在 tableView 代理方法 scrollViewDidScroll(_:) 里面调用
    /// - Parameter tableView: UITableView
    public func updateSelectItemWhenTableViewDidScroll(_ tableView: UITableView) {
        guard !isOnTouch else { return }
        
        guard let index = tableView.indexPathForRow(at: tableView.contentOffset)?.section else { return }
        selectItem(at: index)
    }
}

// MARK: touches 事件
extension XTableViewIndex {
    // 开始
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        guard let item = _getNextItem(touches, with: event) else { return }
        
        isOnTouch = true
        previewItem.alpha = 1.0
        
        _setSelectedItem(item)
    }
    // 移动
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let item = _getNextItem(touches, with: event) else { return }
        
        if !isOnTouch {
            isOnTouch = true
            previewItem.alpha = 1.0
        }
        
        _setSelectedItem(item)
    }
    // 结束
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        isOnTouch = false
        UIView.animate(withDuration: 0.25) { self.previewItem.alpha = 0 }
    }
    // 取消
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        isOnTouch = false
        previewItem.alpha = 0   // 异常退出，不需要增加动画效果
    }
}

// MARK: 私有方法
private extension XTableViewIndex {
    
    /// 初始化设置 subviews
    func _initSetupSubviews() {

        // 添加 subview
        translatesAutoresizingMaskIntoConstraints = false
        previewItem.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(previewItem)
        addSubview(contentStackView)
        
        // 设置约束
        constraints.filter { $0.firstAttribute == .width }.forEach { removeConstraint($0) }
        let widthConstraint = widthAnchor.constraint(equalToConstant: 19.0)
        addConstraint(widthConstraint)
        
        let previewItemWidthConstraint = previewItem.widthAnchor.constraint(equalToConstant: 64.0)
        let previewItemHeightConstraint = previewItem.heightAnchor.constraint(equalToConstant: 46.0)
        let previewItemTrailingConstraint = previewItem.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -17.0)
        let previewItemCenterYConstraint = previewItem.centerYAnchor.constraint(equalTo: centerYAnchor)
        addConstraints([previewItemWidthConstraint,
                        previewItemHeightConstraint,
                        previewItemTrailingConstraint,
                        previewItemCenterYConstraint])
        
        let contentStackViewLeadingConstraint = contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        let contentStackViewTrailingConstraint = contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        let contentStackViewCenterYConstraint = contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        addConstraints([contentStackViewLeadingConstraint,
                        contentStackViewTrailingConstraint,
                        contentStackViewCenterYConstraint])
        
        // 保存约束
        self.previewItemCenterYConstraint = previewItemCenterYConstraint
    }
    
    /// 添加 item
    func _addItemsToContentStackView() {
        // 移除旧的
        items.forEach { $0.removeFromSuperview() }
        // 获取 titles
        guard let titles = dataSource?.indexTitles(for: self), !titles.isEmpty else { return }
        // 生成 item 并添加到 contentStackView
        for (index, title) in titles.enumerated() {
            let item = _makeItem(title: title, index: index)
            contentStackView.addArrangedSubview(item)
            
            item.addConstraints([item.widthAnchor.constraint(equalToConstant: itemWidth),
                                 item.heightAnchor.constraint(equalTo: item.widthAnchor)])
        }
        // 设置默认
        _setSelectedItem(items.first!, needFeedback: false)
    }
    
    /// 生成 item
    /// - Parameters:
    ///   - title: 标题
    ///   - index: 索引
    func _makeItem(title: String, index: Int) -> UILabel {
        let item = UILabel()
        item.tag = index
        item.text = title
        item.textAlignment = .center
        item.font = UIFont.systemFont(ofSize: 10.0)
        item.layer.cornerRadius = itemWidth / 2.0
        item.layer.masksToBounds = true
        return item
    }
    
    /// 更新 items 的宽度
    func _setNeedUpdateItemsWidth() {
        items.forEach {
            $0.constraints
                .filter { $0.firstAttribute == .width }
                .forEach { $0.constant = itemWidth }
        }
    }
    
    /// 更新颜色
    func _setNeedUpdateItemsColor() {
        selectedItem?.textColor = itemSelectedColor
        selectedItem?.backgroundColor = itemSelectedBackgroundColor
        for item in items {
            let isSelected = item == selectedItem
            item.textColor = isSelected ? itemSelectedColor : itemColor
            item.backgroundColor = isSelected ? itemSelectedBackgroundColor : itemColor
        }
    }
    
    /// 设置选择的 item
    /// - Parameters:
    ///   - toItem: 将要设置的 item
    ///   - needFeedback: 需要反馈（震动反馈）默认 true
    ///   - needExecDelegate: 需要执行代理方法 默认 true
    func _setSelectedItem(_ item: UILabel, needFeedback: Bool = true, needExecDelegate: Bool = true) {
        guard selectedItem != item else { return }
        // 1.1 设置为默认样式
        selectedItem?.textColor = itemColor
        selectedItem?.backgroundColor = itemBackgroundColor
        selectedItem?.font = UIFont.systemFont(ofSize: 10)
        
        // 1.2 设置为选中样式
        item.textColor = itemSelectedColor
        item.backgroundColor = itemSelectedBackgroundColor
        item.font = UIFont.systemFont(ofSize: 12)
        
        // 1.3 保存
        selectedItem = item
        
        // 2.1 更新预览标题
        previewItem.setTitle(item.text, for: .normal)
        // 2.2 更新预览item的位置
        if let previewItemCenterYConstraint = previewItemCenterYConstraint {
            removeConstraint(previewItemCenterYConstraint)
        }
        previewItemCenterYConstraint = previewItem.centerYAnchor.constraint(equalTo: item.centerYAnchor)
        addConstraint(previewItemCenterYConstraint!)
        
        // 3 触发震动 只有当 item 新值旧值均不为 nil 才调用
        if needFeedback {
            if #available(iOS 10.0, *) { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        }
        
        // 4 执行代理
        if needExecDelegate {        
            delegate?.tableViewIndex(self, didSelectItemAt: item.tag)
        }
    }
    
    /// 获取下一下点击的 item
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent
    func _getNextItem(_ touches: Set<UITouch>, with event: UIEvent?) -> UILabel? {
        
        guard !items.isEmpty else { return nil }
        
        let touchY = (touches.first as AnyObject).location(in: contentStackView).y
        
        var toItemOptional: UILabel? = nil
        
        if touchY < 0 {
            if selectedItem != items.first! { toItemOptional = items.first! }
        } else if touchY > contentStackView.frame.height {
            if selectedItem != items.last { toItemOptional = items.last! }
        } else {
            toItemOptional = items.first { $0.frame.minY <= touchY && $0.frame.maxY >= touchY }
        }
        
        return toItemOptional
    }
    
    /// 从 bundle 中获取图片
    /// - Parameter named: 图片名称
    /// - Parameter ofType: 图片后缀
    func _getBundleImage(named: String, ofType: String) -> UIImage? {
        let mainBundle = Bundle(for: Self.self)
        guard let bundlePath = mainBundle.path(forResource: String(describing: Self.self), ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let imgPath = bundle.path(forResource: named, ofType: ofType),
            let img = UIImage(contentsOfFile: imgPath) else { return nil }
        return img
    }
}
