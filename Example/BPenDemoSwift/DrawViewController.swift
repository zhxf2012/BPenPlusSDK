//
//  DrawViewController.swift
//  BPenDemoSwift
//
//  Created by HFY on 2020/7/18.
//  Copyright © 2020 bbb. All rights reserved.
//

import UIKit
import BPenPlusSDK


typealias SDKVIEW =  BPCanvasView

/// 本类主要演示：1.如何用原始点进行绘制，包括sdk自带绘制和自定义绘制 2.绘制到图片等图文context中 3.笔迹与底图对齐等
/// 4.本类中做了简单的数据持久，即点数据按页存储在内存中(app重启后会丢失) 从而实现多页笔画切换 （这里数据持久的操作跟绘制是前后进行的，且可能未精确实现增量绘制，性能存疑。实际数据持久和界面绘制响应应该完全分开独立互不影响）
///
///
class DrawViewController: UIViewController {
    enum CanvasType: Int {
        case sdk = 1  //SDK提供的画布，支持每一笔的颜色还每一笔单独的粗细系数
        case custom = 0 //本demo开源的自定义绘制，支持每一笔的颜色以及整个画布共用一个笔画的粗细系数
        
        var title: String {
            switch self {
            case .sdk:
                return "SDK绘制"
            case .custom:
                return "自定义绘制"
            }
        }
    }
    
    @IBOutlet weak var strokeWidthSeg: UISegmentedControl!
  
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var randomStrokeColorButton: UIButton!
    @IBOutlet weak var drawModeSeg: UISegmentedControl!
  
   @IBOutlet weak var paperTypeLabel: UILabel!
   @IBOutlet weak var pageIdLabel: UILabel!
   @IBOutlet weak var pageSwitchButton: UIButton!
   
   //var allPoints:[BPPoint] = []
   var dataManager =  BPPointsDAO()
   
   var currentPage = BPSinglePage()
    
    fileprivate var strokeColor: UIColor = UIColor.cyan {
        didSet {
            self.customCanvas.strokeColor = strokeColor
//            self.sdkCanvas.drawlayer.strokeColor = strokeColor
        }
    }
   
   fileprivate var strokeWidth: CGFloat = 1.0 {
      didSet {
         self.customCanvas.strokeWidthScale = strokeWidth
      }
   }
    
    var selectCanvasType: CanvasType =  .custom {
        didSet {
            if oldValue != selectCanvasType {
                 let old = canvasForType(oldValue)
                old.removeFromSuperview()
                
                let new = canvasForType(selectCanvasType)
                scrollView.addSubview(new)
                new.frame = scrollView.bounds
                
                scrollView.zoomScale = 1
                scrollView.setNeedsDisplay()
            }
        }
    }
    
    fileprivate lazy var sdkCanvas: SDKVIEW = {
        let size: CGSize
        if #available(iOS 11.0, *) {
              size = self.scrollView.safeAreaLayoutGuide.layoutFrame.size
        } else {
            // Fallback on earlier versions
            size = self.scrollView.bounds.size
        }
        let canvas = SDKVIEW.init(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
        canvas.backgroundColor = .clear
        canvas.autoresizingMask = [.flexibleWidth ,.flexibleHeight]
        return canvas
    }()
    
    fileprivate lazy var customCanvas: MyCanvasView = {
        let size: CGSize
        if #available(iOS 11.0, *) {
              size = self.scrollView.safeAreaLayoutGuide.layoutFrame.size
        } else {
            // Fallback on earlier versions
            size = self.scrollView.bounds.size
        }
        let canvas = MyCanvasView.init(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
        canvas.backgroundColor = .clear
        canvas.autoresizingMask = [.flexibleWidth ,.flexibleHeight]
        return canvas
    }()
    
    func canvasForType(_ type:CanvasType) -> UIView {
        switch type {
        case .sdk:
            return self.sdkCanvas
        case .custom:
            return self.customCanvas
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       if #available(iOS 13.0, *) {
          self.view.backgroundColor = UIColor.systemBackground
       } else {
          // Fallback on earlier versions
          self.view.backgroundColor = UIColor.white
       }
         
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 8
        
        strokeColor = .blue
         
        for value in [CanvasType.custom,CanvasType.sdk] {
            self.drawModeSeg.setTitle(value.title, forSegmentAt: value.rawValue)
        }
        
        for (index,item) in strokeWidths.enumerated() {
            self.strokeWidthSeg.setTitle("\(item)", forSegmentAt: index)
        }
    }
    
    let strokeWidths:[CGFloat] = [0.5,1,1.5,2,2.5]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        strokeWidthSeg.selectedSegmentIndex = 1
        self.selectCanvasType = .sdk
        drawModeSeg.selectedSegmentIndex = 1
    }
   
   func handelPointsDraw(pageChanged: Bool,currentPage:BPSinglePage,redrawPoints:[BPPoint]) {
      let paperType = "\(currentPage.points.first?.paperType.rawValue ?? 0)"
      let pageId = "\(currentPage.points.first?.pageId ?? 0)"
      if paperType != self.paperTypeLabel.text {
         self.paperTypeLabel.text = paperType
      }
      
      if pageId != self.pageIdLabel.text {
         self.pageIdLabel.text = pageId
      }
      
      if(pageChanged) {
         let index = dataManager.pages.firstIndex(of: currentPage) ?? 0
         let pageTitle = "\(index + 1)/\(dataManager.pages.count)"
         pageSwitchButton.setTitle(pageTitle, for: .normal)
         
         self.currentPage = currentPage
         sdkCanvas.clearCanvas()
         customCanvas.clearCanvas()
         sdkCanvas.updateCanvasWtihBack(nil, imageDPI: 300)
         customCanvas.updateCanvasWtihBack(nil, imageDPI: 300)
      }
      
      sdkCanvas.drawing(withRealtimePoints: redrawPoints, stroke: strokeColor, strokeWidthScale: strokeWidth)
      customCanvas.drawing(withRealtimePoints: redrawPoints, stroke: strokeColor, strokeWidthScale: strokeWidth)
 

      if let point = redrawPoints.first ,let paperBgImageName = paperImageNameForPaper(point.paperType,pageId:point.pageId),paperBgImageName != backImageName,let image = UIImage(named: paperBgImageName) {
          backImageName = paperBgImageName
          //本demo工程目录下的底图图片为A5P的本子底图，dpi为300 故仅仅演示该底图的对齐效果。如您手上有棒棒帮A5P的本子，可以用智慧笔在本子上书写，然后看到此处实现的对齐效果
          sdkCanvas.updateCanvasWtihBack(image, imageDPI: 300)
          customCanvas.updateCanvasWtihBack(image, imageDPI: 300)
      }
   }
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
   @IBAction func pageSwtichTouched(_ sender: Any) {
      if !dataManager.pages.isEmpty {
         var items: [UIAlertAction] = []
         for page in dataManager.pages {
            let action = UIAlertAction.init(title: page.indexKey, style: .default) {[weak self] _ in
               self?.handelPointsDraw(pageChanged: true, currentPage: page, redrawPoints: page.points)
            }
            items.append(action)
         }
         showAlert(title: "多页数据", message: "切换到", confirm: nil, cancel: nil,otherActions: items)
      }
   }
   
   @IBAction func randomStrokeColorButtonTouched(_ sender: Any) {
        let r: CGFloat = CGFloat(arc4random()%255)
        let g: CGFloat = CGFloat(arc4random()%255)
        let b: CGFloat = CGFloat(arc4random()%255)
        self.strokeColor = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
        DispatchQueue.main.async {
            [weak self] in
            self?.randomStrokeColorButton.setTitleColor(self?.strokeColor, for: .normal)
            
        }
    }
    
    @IBAction func drawModeSegValueChanged(_ sender: Any) {
        guard let type = CanvasType(rawValue:self.drawModeSeg.selectedSegmentIndex) else {
            return
        }
        self.selectCanvasType = type
    }
    
    @IBAction func lineWidthSegValueChanged(_ sender: Any) {
        let width = strokeWidths[self.strokeWidthSeg.selectedSegmentIndex]
        //sdkCanvas.strokeWidthScale = width
      self.strokeWidth = width
    }
    
    var backImageName: String?
    func paperImageNameForPaper(_ type: BPaperType, pageId: CUnsignedLongLong) -> String? {
       
      let imageName = "\(type.rawValue)_\(pageId)"
      if let _ = UIImage(named: imageName) {  // 如果要测试某页对齐，只需在本demo中放入papertype_pageId命名的底图图片即可（如本demo已内置底图0_46572.png 即A4P（paperType为0）类型的pageId为46572的图），默认底图分辨率为300，如果放入的底图dpi不是300 请在加载此imageName的图片并传入canvas时传入实际的dpi，详见本demo中此方法调用的地方
         return imageName
      }
      
        guard type == .A5P  else {
            //如未在本demo的target中按上面命名的内置底图，则本demo仅展示 A5P 类型的纸张的对齐效果
            return nil
        }
        
        let name = "Paper_A5P" + ((pageId % 2 == 0) ? "_Left" : "_Right")
        return name
    }
    
    func realTimeDrawing(_ data: [BPPoint]?) {
       dataManager.processPoints(data ?? [], completed: {[weak self]  change, page, points  in
          self?.handelPointsDraw(pageChanged: change, currentPage: page, redrawPoints: points)
       })
       /*
      customCanvas.drawing(withRealtimePoints: data ?? [], stroke: strokeColor, strokeWidthScale: strokeWidth)
      sdkCanvas.drawing(withRealtimePoints: data ?? [], stroke: strokeColor, strokeWidthScale: strokeWidth)
      
        if data?.first?.pageId != allPoints.last?.pageId {
            allPoints.removeAll()
        }
        
        allPoints.append(contentsOf: data ?? [])
      let paperType = "\(allPoints.first?.paperType.rawValue ?? 0)"
      let pageId = "\(allPoints.first?.pageId ?? 0)"
      if paperType != self.paperTypeLabel.text {
         self.paperTypeLabel.text = paperType
      }
      
      if pageId != self.pageIdLabel.text {
         self.pageIdLabel.text = pageId
      }
        
        if let point = data?.first ,let paperBgImageName = paperImageNameForPaper(point.paperType,pageId:point.pageId),paperBgImageName != backImageName,let image = UIImage(named: paperBgImageName) {
            backImageName = paperBgImageName
            //本demo工程目录下的底图图片为A5P的本子底图，dpi为300 故仅仅演示该底图的对齐效果。如您手上有棒棒帮A5P的本子，可以用智慧笔在本子上书写，然后看到此处实现的对齐效果
            sdkCanvas.updateCanvasWtihBack(image, imageDPI: 300)
            customCanvas.updateCanvasWtihBack(image, imageDPI: 300)
        }
        */
    }
    
    func batchDrawing(_ data: [BPPoint]?) {
       dataManager.processPoints(data ?? [], completed: {[weak self]  change, page, points  in
          self?.handelPointsDraw(pageChanged: change, currentPage: page, redrawPoints: points)
       })
       /*
      customCanvas.drawing(withNonRealtimePoints: data ?? [], stroke: strokeColor, strokeWidthScale: strokeWidth)
      sdkCanvas.drawing(withNonRealtimePoints: data ?? [], stroke: strokeColor, strokeWidthScale: strokeWidth)
        
        if data?.first?.pageId != allPoints.last?.pageId {
            allPoints.removeAll()
        }
        
        allPoints.append(contentsOf: data ?? [])
        
        if let point = data?.first ,let paperBgImageName = paperImageNameForPaper(point.paperType,pageId:point.pageId),paperBgImageName != backImageName,let image = UIImage(named: paperBgImageName) {
            backImageName = paperBgImageName
            //本demo工程目录下的底图图片为A5P的本子底图，dpi为300 故仅仅演示该底图的对齐效果。如您手上有棒棒帮A5P的本子，可以用智慧笔在本子上书写，然后看到此处实现的对齐效果
            sdkCanvas.updateCanvasWtihBack(image, imageDPI: 300)
            customCanvas.updateCanvasWtihBack(image, imageDPI: 300)
        }
        */
    }
   
   //本方法演示如何持久化笔迹点数据
   @IBAction func exportDataButtonTouched(_ sender: Any) {
      let page = customCanvas.render.generateCodablePageData()
      do {
         let data = try JSONEncoder().encode(page)
         var temp  =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
         temp.appendPathComponent("temp.json")
         try data.write(to: temp)
         
         //分享保存原生数据
           let activeView = UIActivityViewController.init(activityItems: [temp], applicationActivities: nil)
           activeView.popoverPresentationController?.sourceView = self.view
           activeView.popoverPresentationController?.sourceRect = .zero
           self.present(activeView, animated: true, completion: nil)
         
      } catch {
         print(error)
      }
   }
   
    //本方法演示如何绘制笔迹点为图片
    @IBAction func drawAsImage(_ sender: Any) {
        //1.初始化图片渲染器
        let imageRender = BPCanvasImageRender.init()
        
        //2.笔画粗细系数，默认1.0 可自行设置其他正值 ,自1.8起支持每一笔单独设置线宽系数，参照下面4
//        imageRender.strokeWidthScale = 1.0
        
       if let point = currentPage.points.first ,let paperBgImageName = paperImageNameForPaper(point.paperType,pageId:point.pageId), let image = UIImage(named: paperBgImageName) {
            //3.设置底图 底图可选是否传入
            imageRender.updateCanvasWtihBack(image, imageDPI: 300)
        }
        
        //4.绘制笔迹点 ，若各笔划颜色,粗细不一样，可按笔画多次调用此方法绘制；目前不支持多页的点绘制在一页上
       imageRender.drawing(withNonRealtimePoints: currentPage.points, stroke: strokeColor,strokeWidthScale: strokeWidth)
        
        //5. 生成分享图片
        let result = imageRender.getCurrentCavasImage(withBackImage: true)
        
      //分享保存图片
        let activeView = UIActivityViewController.init(activityItems: [result], applicationActivities: nil)
        activeView.popoverPresentationController?.sourceView = self.view
        activeView.popoverPresentationController?.sourceRect = .zero
        self.present(activeView, animated: true, completion: nil)
    }
}

extension DrawViewController: UIScrollViewDelegate {
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let newScale = scrollView.zoomScale * (self.scrollView.window?.screen.scale ?? 1)
        print("newScale :\(newScale),scrollView.zoomScale:\(scrollView.zoomScale),scale:\(scale)");
//        canvas.contentScaleFactor = newScale
        canvasForType(selectCanvasType).contentScaleFactor = newScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasForType(selectCanvasType)
    }
}
