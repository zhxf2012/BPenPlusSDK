//
//  MyCanvasView.swift
//  BPenDemoSwift
//
//  Created by HFY on 2020/11/27.
//  Copyright © 2020 bbb. All rights reserved.
//

import UIKit
import BPenPlusSDK

//渲染用的数据处理类，此处完全基于原始物理坐标点处理数据，其实可以自行把其转换为屏幕上点（转换实现详见下面的MyCanvas实现）
class MyCanvasRender: NSObject {
    fileprivate class Stroke: NSObject {
        private(set) var points: [BPPoint] = []
        var color: UIColor = .black
        private var minX: CGFloat = .infinity
        private var minY: CGFloat = .infinity
        private var maxX: CGFloat = 0
        private var maxY: CGFloat = 0
        
        var boundingBox: CGRect {
            return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        }
        
        func appendPoint(_ point: BPPoint) {
            minY = min(minY,CGFloat(point.y))
            minX = min(minX,CGFloat(point.x))
            maxY = max(maxY,CGFloat(point.y))
            maxX = max(maxX,CGFloat(point.x))
            points.append(point)
        }
        
        var codableStroke: MyStroke {
            let aStroke = MyStroke()
            for point in points {
                let aPoint = MyPoint(x: point.x, y: point.y, width: Float(point.width))
                aStroke.points.append(aPoint)
            }
            return aStroke
        }
    }
    
    fileprivate class Page: NSObject {
        private(set) var strokes: [Stroke] = []
        private(set) var paperType: BPaperType?
        private(set) var pageId: CUnsignedLongLong?
        
        fileprivate var color: UIColor = .black
        
        var currentStroke: Stroke? {
            return strokes.last
        }
    
        func appendPoint(_ point: BPPoint,dirtyRectHandel:((CGRect?) -> Void)) {
            guard pageId == point.pageId,paperType == point.paperType else {
                //换页了 清除之前的
                strokes.removeAll()
                dirtyRectHandel(nil)
                pageId = point.pageId
                paperType = point.paperType
                appendPoint(point,dirtyRectHandel: dirtyRectHandel)
                return
            }
            
            guard !point.strokeStart  else{
                //新的一笔
                let stroke = Stroke.init()
                stroke.appendPoint(point)
                strokes.append(stroke)
                stroke.color = color
                dirtyRectHandel(stroke.boundingBox)
                return
            }
            
            guard !point.strokeEnd else {
                // 可以自行在此处实现笔锋效果
                return
            }
            
            guard let last = strokes.last else {
                return
            }
            
            last.appendPoint(point)
            dirtyRectHandel(last.boundingBox)
        }
    }
   
    fileprivate var page: Page = .init()
     
    
    //刷新指定区域，区域为空时,需要刷新整个区域
    var dispayDirtyRectHandel:((CGRect?) -> Void)?
    
    func appendPoints(_ points: [BPPoint],strokeColor: UIColor) {
        page.color = strokeColor
        points.forEach {
            appendPoint($0)
        }
    }

    private func appendPoint(_ point: BPPoint) {
        page.appendPoint(point) { dirtyRect in
            dispayDirtyRectHandel?(dirtyRect)
        }
    }
    
    func clearCanvas() {
        
    }
}

extension BPaperType: Codable {
    
}

extension MyCanvasRender {
    struct MyPoint: Codable {
        var x: Float
        var y: Float
        var width: Float
    }
    
    class MyStroke: Codable {
        var points: [MyPoint] = []
    }
    
    class MyPage: Codable {
        var strokes: [MyStroke] = []
        var paperType: BPaperType?
        var pageId: CUnsignedLongLong?
    }
    
    func generateCodablePageData() -> MyPage {
        let result = MyPage()
        result.pageId = page.pageId
        result.paperType = page.paperType
        for stroke in page.strokes {
            result.strokes.append(stroke.codableStroke)
        }
        return result
    }
}

struct BackgroundImage {
    var image: UIImage
    var dpi: CGFloat
    
    //底图的物理尺寸 单位毫米 mm
    var physicSize: CGSize {
        guard dpi > 0 else {
            return .zero
        }
        
        let width = image.size.width / dpi * 25.4 //一英寸25.4mm
        let height = image.size.height / dpi * 25.4
        return .init(width: width, height: height)
    }
}

fileprivate class MyCanvas: UIView {
    
    var strokeWidthScale: CGFloat = 1  {
        didSet {
            self.updateNowWithRect()
        }
    }
    
    lazy var render: MyCanvasRender = {
        let render = MyCanvasRender.init()
        render.dispayDirtyRectHandel = {[weak self] dirtyRect in
            self?.updateNowWithRect(dirtyRect)
        }
        return render
    }()
            
    func updateNowWithRect(_ dirtyRect: CGRect? = nil) {
        safeAsyncWithBlock { [weak self] in
            if let dirtyRect = dirtyRect {
                let dirRectInView = self?.rectInViewForPaperArea(dirtyRect) ?? dirtyRect
                self?.setNeedsDisplay(dirRectInView)
            } else {
                self?.setNeedsDisplay()
            }
        }
    }
    
    func safeAsyncWithBlock(_ block: @escaping (() -> Void)) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    var strokeColor: UIColor = UIColor.cyan {
        didSet {
            self.updateNowWithRect()
        }
    }
    
    override var contentScaleFactor: CGFloat {
        didSet {
            self.updateNowWithRect()
        }
    }
    
    func drawing(_ data: [BPPoint],strokeColor: UIColor) {
        render.appendPoints(data,strokeColor: strokeColor)
    }

    var backImage: BackgroundImage? {
        didSet {
            canvasRect = getTheCanvasRect()
        }
    }
    
    var paperPhysicSize: CGSize {
        guard let backImage = backImage else {
            guard let pageType = render.page.paperType else {
                if #available(iOS 11.0, *) {
                    return self.safeAreaLayoutGuide.layoutFrame.size
                } else {
                    // Fallback on earlier versions
                    return self.bounds.size
                }
            }
            
            return BPaperTypeHelper.maxContentSizeInMM(for: pageType)
        }
        
        return backImage.physicSize
    }
    
    private func getTheCanvasRect() -> CGRect {
        let viewSize: CGSize
        if #available(iOS 11.0, *) {
              viewSize = self.safeAreaLayoutGuide.layoutFrame.size
        } else {
            // Fallback on earlier versions
            viewSize = self.bounds.size
        };
        var drawSize = viewSize;
        if ((viewSize.width / viewSize.height) > (paperPhysicSize.width / paperPhysicSize.height)) {
            drawSize.width =  viewSize .height * paperPhysicSize.width / paperPhysicSize.height;
            drawSize.height = drawSize.width * paperPhysicSize.height / paperPhysicSize.width;
        } else {
            drawSize.height =  viewSize.width * paperPhysicSize.height / paperPhysicSize.width;
            drawSize.width = drawSize.height * paperPhysicSize.width / paperPhysicSize.height;
        }
        return   CGRect(x: self.center.x - drawSize.width/2.0, y: self.center.y - drawSize.height/2.0, width: drawSize.width, height: drawSize.height);
    }
    
    //画布视图中按照纸张长宽比最大的居中的绘制区域
    lazy var canvasRect: CGRect = {
        return getTheCanvasRect()
    }()
    
    func positonInViewForPaperPoint(_ point:CGPoint) -> CGPoint {
        let canvasSize = canvasRect.size
        let canvasOrigin = canvasRect.origin
        let x = canvasOrigin.x + point.x / paperPhysicSize.width * canvasSize.width
        let y = canvasOrigin.y + point.y / paperPhysicSize.height * canvasSize.height
        return CGPoint(x: x, y: y)
    }
    
    func rectInViewForPaperArea(_ area: CGRect) -> CGRect {
        let newOrigin = positonInViewForPaperPoint(area.origin)
        let width = area.size.width / paperPhysicSize.width * canvasRect.width
        let height = area.size.height / paperPhysicSize.height * canvasRect.height
        return .init(origin: newOrigin, size: CGSize(width: width, height: height))
    }
    
    func clearCanvas() {
        render.clearCanvas()
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let date_begain = CFAbsoluteTimeGetCurrent();
        
        UIGraphicsPushContext(context)
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setFlatness(0.7)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        
        self.strokeColor.setFill()
        self.strokeColor.setStroke()
        
        for (_,item) in render.page.strokes.enumerated() {
            
            //在指定的矩形内才绘制 调用updateCavans(dirtyRect) rect即dirtyRect
            if rect.intersects(rectInViewForPaperArea(item.boundingBox)) {
                for (index,point) in item.points.enumerated() {
                    if index > 0 {
                        context.move(to: positonInViewForPaperPoint(item.points[index-1].position) )
                        context.addLine(to: positonInViewForPaperPoint(point.position))
                        context.setLineWidth(CGFloat(point.width) * strokeWidthScale )
                        context.drawPath(using: .fillStroke)
                    }
                }
            }
        }
        
        let date_end =  CFAbsoluteTimeGetCurrent();
        debugPrint("Canvas drawRect Time: \((1000 * Float(date_end - date_begain))) 毫秒");
    }
}

//本类为演示 自定义实现笔迹和底图对齐,线宽，颜色等功能的 示例。实现笔迹和背景底图对齐的方案说明详见随SDK附带的文档 “画布与底图对齐实现的技术细节.pdf”，本类中相关数据处理和绘制实现仅仅演示如何实现，不保证性能和好的效果,若觉得自定义绘制过于复杂和难以优化性能，也可以直接采用SDK中性能效果更好的BPCanvasView。如有更好效果更高效率的实现，可以联系本人交流：zhouxingfa@bibibetter.com
class MyCanvasView: UIView,BPCanvasRenderDelegate {
    func drawing(withNonRealtimePoints points: [BPPoint], stroke color: UIColor, strokeWidthScale: CGFloat) {
        canvas.drawing(points, strokeColor: color)
    }
    
    func drawing(withRealtimePoints points: [BPPoint], stroke color: UIColor, strokeWidthScale: CGFloat) {
        canvas.drawing(points, strokeColor: color)
    }
    
    func updateCanvasWtihContentPhysicSize(_ physicSize: CGSize) {
         
    }

    func clearCanvas() {
        canvas.clearCanvas()
    }
    
    func updateCanvasWtihBack(_ image: UIImage?, imageDPI dpi: CGFloat) {
        guard let image = image else {
            return
        }
        
        backImage = .init(image: image, dpi: dpi)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backImageView)
        self.addSubview(canvas)
        self.sendSubviewToBack(backImageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubview(backImageView)
        self.addSubview(canvas)
        self.sendSubviewToBack(backImageView)
    }
    
    fileprivate lazy var canvas: MyCanvas = {
        let view = MyCanvas(frame: self.bounds)
        view.backgroundColor = .white
        return view
    }()
    
    var render: MyCanvasRender {
        return canvas.render
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustCanvasSize()
    }
    
    func adjustCanvasSize() {
        DispatchQueue.main.async {
            self.canvas.backImage = self.backImage
            self.backImageView.image = self.backImage?.image
            self.backImageView.frame = self.canvas.canvasRect
        }
    }
    
    var backImage: BackgroundImage? {
        didSet {
           adjustCanvasSize()
        }
    }
    
    fileprivate lazy var backImageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        return imageView
    }()
    
    
    var strokeColor: UIColor = UIColor.cyan {
        didSet {
            self.canvas.strokeColor = strokeColor
        }
    }
    
    var strokeWidthScale: CGFloat = 1  {
        didSet {
            self.canvas.strokeWidthScale = strokeWidthScale
        }
    }
}
