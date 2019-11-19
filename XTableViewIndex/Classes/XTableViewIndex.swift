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

@IBDesignable
final public class XTableViewIndex: UIView {
    
    /// 宽度
    public static var width: CGFloat = 19.0
    
    /// item 的宽度
    public static var itemWidth: CGFloat = 13.0
    
    /// item 默认颜色（默认：#44557D）
    public static var itemTextColor: UIColor = #colorLiteral(red: 0.2666666667, green: 0.3333333333, blue: 0.4901960784, alpha: 1)
    /// item 选中颜色（默认：.white）
    public static var itemSelectedTextColor: UIColor = .white
    
    /// item 默认背景色（默认：.clear）
    public static var itemBackgroundColor: UIColor = .clear
    /// item 选中背景色（默认：#FF7721）
    public static var itemSelectedBackgroundColor: UIColor = #colorLiteral(red: 1, green: 0.4666666667, blue: 0.1294117647, alpha: 1)
    
    /// item 默认字体（默认：.systemFont(ofSize: 10.0)）
    public static var itemFont: UIFont = .systemFont(ofSize: 10.0)
    /// item 选中字体（默认：.systemFont(ofSize: 10.0)）
    public static var itemSelectedFont: UIFont = .systemFont(ofSize: 10.0)
    
    /// 宽度
    @IBInspectable public var width: CGFloat = XTableViewIndex.width {
        didSet { widthConstraint.constant = width }
    }
    
    /// item 的宽度
    @IBInspectable public var itemWidth: CGFloat = XTableViewIndex.itemWidth {
        didSet {
            guard oldValue != itemWidth else { return }
            _setNeedUpdateItemsWidth()
        }
    }
    
    /// item 默认颜色（默认：#44557D）
    @IBInspectable public var itemTextColor: UIColor = XTableViewIndex.itemTextColor {
        didSet {
            guard oldValue != itemTextColor else { return }
            _setNeedUpdateItemsColor()
        }
    }
    /// item 选中颜色（默认：.white）
    @IBInspectable public var itemSelectedTextColor: UIColor = XTableViewIndex.itemSelectedTextColor {
        didSet {
            guard oldValue != itemSelectedTextColor else { return }
            _setNeedUpdateItemsColor()
        }
    }
    
    /// item 默认背景色（默认：.clear）
    @IBInspectable public var itemBackgroundColor: UIColor = XTableViewIndex.itemBackgroundColor {
        didSet {
            guard oldValue != itemBackgroundColor else { return }
            _setNeedUpdateItemsColor()
        }
    }
    /// item 选中背景色（默认：#FF7721）
    @IBInspectable public var itemSelectedBackgroundColor: UIColor = XTableViewIndex.itemSelectedBackgroundColor {
        didSet {
            guard oldValue != itemSelectedBackgroundColor else { return }
            _setNeedUpdateItemsColor()
        }
    }
    
    /// item 默认字体
    public var itemFont: UIFont = XTableViewIndex.itemFont {
        didSet {
            guard oldValue != itemFont else { return }
            _setNeedUpdateItemsFont()
        }
    }
    /// item 选中字体
    public var itemSelectedFont: UIFont = XTableViewIndex.itemSelectedFont {
        didSet {
            guard oldValue != itemSelectedFont else { return }
            _setNeedUpdateItemsFont()
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
    
    /// 拖拽手势
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
    
    /// 宽度约束
    private lazy var widthConstraint = widthAnchor.constraint(equalToConstant: width)
    
    /// 预览 item 的 centerY 约束
    private lazy var previewItemCenterYConstraint = previewItem.centerYAnchor.constraint(equalTo: centerYAnchor)
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _initSetup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        _initSetup()
    }
    
    /// 刷新数据
    public func reloadData() {
        _addItemsToContentStackView()
    }
    
    /// 选中的 item
    /// - Parameter index: 索引
    public func selectItem(at index: Int) {
        guard index >= 0 && index < items.count && index != selectedItem?.tag else { return }
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
    
    // 为了早点触发 pan 手势
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        pan.setTranslation(
            (touches.first as AnyObject).location(in: contentStackView),
            in: contentStackView
        )
    }
    
    @objc private func panAction(_ pan: UIPanGestureRecognizer) {
        
        let touchY = pan.location(in: contentStackView).y
        
        switch pan.state {
            
        case .began:
            guard let item = _getSelectItemInContentStackView(with: touchY) else { return }
            isOnTouch = true
            previewItem.alpha = 1.0
            
            _setSelectedItem(item)
        case .changed:
            guard let item = _getSelectItemInContentStackView(with: touchY) else { return }
            
            if !isOnTouch {
                isOnTouch = true
                previewItem.alpha = 1.0
            }
            
            _setSelectedItem(item)
        case .ended:
            isOnTouch = false
            UIView.animate(withDuration: 0.25) { self.previewItem.alpha = 0 }
        case .cancelled:
            print("取消")
            
            isOnTouch = false
            previewItem.alpha = 0   // 异常退出，不需要增加动画效果
        default:
            break
        }
        
    }
}

// MARK: 私有方法
private extension XTableViewIndex {
    
    /// 初始化设置 subviews
    func _initSetup() {
        
        // 设置约束
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(widthConstraint)
        
        addSubview(previewItem)
        previewItem.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            previewItemCenterYConstraint,
            previewItem.widthAnchor.constraint(equalToConstant: 64.0),
            previewItem.heightAnchor.constraint(equalToConstant: 46.0),
            previewItem.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -17.0)
        ])
        
        addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // 添加手势
        addGestureRecognizer(pan)
        
        layoutIfNeeded()
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
        item.textColor = itemTextColor
        item.font = itemFont
        item.backgroundColor = itemBackgroundColor
        item.textAlignment = .center
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
        items.forEach {
            let isSelected = $0 == selectedItem
            $0.textColor = isSelected ? itemSelectedTextColor : itemTextColor
            $0.backgroundColor = isSelected ? itemSelectedBackgroundColor : itemTextColor
        }
    }
    
    /// 更新文字大小
    func _setNeedUpdateItemsFont() {
        items.forEach {
            let isSelected = $0 == selectedItem
            $0.font = isSelected ? itemSelectedFont : itemFont
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
        selectedItem?.textColor = itemTextColor
        selectedItem?.backgroundColor = itemBackgroundColor
        selectedItem?.font = itemFont
        
        // 1.2 设置为选中样式
        item.textColor = itemSelectedTextColor
        item.backgroundColor = itemSelectedBackgroundColor
        item.font = itemSelectedFont
        
        // 1.3 保存
        selectedItem = item
        
        // 2.1 更新预览标题
        previewItem.setTitle(item.text, for: .normal)
        // 2.2 更新预览item的位置
        removeConstraint(previewItemCenterYConstraint)
        previewItemCenterYConstraint = previewItem.centerYAnchor.constraint(equalTo: item.centerYAnchor)
        addConstraint(previewItemCenterYConstraint)
        
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
    /// - Parameter touchY: contentStackView中 点击的 y 坐标
    func _getSelectItemInContentStackView(with touchY: CGFloat) -> UILabel? {
        
        guard !items.isEmpty else { return nil }
        
        var selectItem: UILabel? = nil
        
        if touchY < 0 {
            // 不是第一个
            if selectedItem != items.first! { selectItem = items.first! }
        } else if touchY > contentStackView.frame.height {
            // 不是最后一个
            if selectedItem != items.last { selectItem = items.last! }
        } else {
            // 中间的
            selectItem = items.first { $0.frame.minY <= touchY && $0.frame.maxY >= touchY }
        }
        
        return selectItem
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
