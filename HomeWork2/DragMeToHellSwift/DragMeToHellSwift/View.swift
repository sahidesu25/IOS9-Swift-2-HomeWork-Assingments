//
//  View.swift
//  DragMeToHellSwift
//  CIS: 651 , Homework 2
//  Authors: Sahithi Lakshmi Desu 
//  Copyright © 2016 . All rights reserved.
//

import UIKit

class MyView: UIView {

    var dw : CGFloat = 0;  var dh : CGFloat = 0    // width and height of cell
    var x : CGFloat = 0;   var y : CGFloat = 0     // touch point coordinates
    var row : Int = Int(arc4random_uniform(10));
    var col : Int = 0 ;       // selected cell in cell grid
    var inMotion : Bool = false// true iff in process of dragging
    var obstaclePointsList:[CGPoint] = [ ]
    var flag = 0 // flag to check if the angel has encountered the obstacle
    var angel_flag = 0 //flag to keep the check of angel
    var success = false // flag that checks if the angel has reached the last row successfully
    
    override init(frame: CGRect) {
        print( "init(frame)" )
        super.init(frame: frame)
        

    }

    required init?(coder aDecoder: NSCoder) {
        print( "init(coder)" )
        super.init(coder: aDecoder)
        obstacleCoordinateGeneration()
      
        
    }
    
    // function that generates unique random (x,y) coordinates for the obstacles, checks if the angel and the obstacle are overlapped, checks if new obstacle is in boundaries of existing obstacle points to ensure clear path
    
     func obstacleCoordinateGeneration(){
        while(true) {
            
            let x_random_row: Int = Int(arc4random_uniform(10))
            let y_random_col :Int = Int(arc4random_uniform(10))
            let point = CGPointMake(CGFloat(x_random_row), CGFloat(y_random_col))
            let initial_angel_point = CGPointMake(CGFloat(row), CGFloat(col))
            var checkOverlap = false // flag to check if the new obstacle point overlaps existing obstacle point
            var checkInvalidPoint = false // flag to check if the new obstacle point is in boundaries of existing obstacle point
            var invalidPointsList:[CGPoint]=[]
            if(point == initial_angel_point) // checks if the obstacle and the angel are not overlapped at the start of the game
            {
                
                continue;
            }
            
            for point_ in obstaclePointsList
            {
                if(point == point_ ) // checks if the obstacles are not overlapped over each other
                {
                    checkOverlap = true
                    break;
                }
                
                invalidPointsList = clearPathCheck(point_) //creates list of boundary points for existing obstacle point
                for invalidPoint in invalidPointsList
                {
                    if(point == invalidPoint) // checks if the new point lies in the boundaries of existing obstacle point. If it does, we skip that obstacle point and generate a new obstacle point
                    {
                        checkInvalidPoint = true
                        break;
                    }
                    
                }
                
                if(checkInvalidPoint)
                {
                    break;
                }
                
            }
            
            if (checkOverlap)//if the new obstacle point overlaps existing point, generate new obstacle point
            {
                continue;
            }
            else if(checkInvalidPoint)// if new obstacle point lies in boundaries of existing obstacle point, generate new obstacle point
            {
                continue;
            }
            else // if both the above checks are false then add the new obstacle point to the list
            {
                obstaclePointsList.append(point)
            }
            
            if(obstaclePointsList.count == 15) // No. of Obstacles is 15
            {
                break;
            }
            
        }
        
    }
    
    //function that generates list of invalid points where next obstacle should not be placed in order to have a clear path. We are achieving this by checking the boundaries of existing obstacle and not placing  the new obstacle in the boundaries of existing obstacles. By doing so we give enough space for angel at any position in first row to reach the last row with a clear path.
    
    func clearPathCheck(point: CGPoint)-> [CGPoint] {
        
        var invalidPointsList:[CGPoint] = [ ]
        invalidPointsList.append(CGPointMake(CGFloat(point.x - 1), CGFloat(point.y)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x + 1), CGFloat(point.y)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x), CGFloat(point.y + 1)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x), CGFloat(point.y - 1)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x + 1), CGFloat(point.y + 1)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x - 1), CGFloat(point.y + 1)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x + 1), CGFloat(point.y - 1)))
        invalidPointsList.append(CGPointMake(CGFloat(point.x - 1), CGFloat(point.y - 1)))
        return invalidPointsList
        
    }
    
    override func drawRect(rect: CGRect) {
        print( "drawRect:" )
        
        let context = UIGraphicsGetCurrentContext()!  // obtain graphics context
        // CGContextScaleCTM( context, 0.5, 0.5 )  // shrink into upper left quadrant
        let bounds = self.bounds          // get view's location and size
        let w = CGRectGetWidth( bounds )   // w = width of view (in points)
        let h = CGRectGetHeight( bounds )// h = height of view (in points)
        self.dw = w/10.0                      // dw = width of cell (in points)
        self.dh = h/10.0// dh = height of cell (in points)
       

        print( "view (width,height) = (\(w),\(h))" )
        print( "cell (width,height) = (\(self.dw),\(self.dh))" )
       
        
        // draw lines to form a 10x10 cell grid
        CGContextBeginPath( context )               // begin collecting drawing operations
        for i in 1..<10 {
            // draw horizontal grid line
            let iF = CGFloat(i)
            CGContextMoveToPoint( context, 0, iF*(self.dh) )
            CGContextAddLineToPoint( context, w, iF*self.dh )
        }
       for i in 1..<10 {
            // draw vertical grid line
            let iFlt = CGFloat(i)
            CGContextMoveToPoint( context, iFlt*self.dw, 0 )
            CGContextAddLineToPoint( context, iFlt*self.dw, h )
        }
        UIColor.grayColor().setStroke()                        // use gray as stroke color
        CGContextDrawPath( context, CGPathDrawingMode.Stroke ) // execute collected drawing ops
        
        // placing the obstacles at the points generated
        for point in self.obstaclePointsList
        {
            let imageRect_obs = CGRectMake(point.x*self.dw, point.y*self.dh, self.dw, self.dh)
            let obstacle_img :UIImage?
            
            obstacle_img = UIImage(named:"obstaclee.png")
            obstacle_img!.drawInRect(imageRect_obs)
            
        }
        
        // establish bounding box for image
        let tl = self.inMotion ? CGPointMake( self.x, self.y )
                               : CGPointMake( CGFloat(row)*self.dw, CGFloat(col)*self.dh )
        
        
        let imageRect = CGRectMake(tl.x, tl.y, self.dw, self.dh)
                
        // place appropriate image
        var img : UIImage?
       
        if(self.flag == 1) // once the angel encounters obstacle, the flag is 1 and hence this check
        {
            img = UIImage(named:"devil.png")
            self.backgroundColor = UIColor.redColor()
            flag = 0 // resetting the flag for next checks
            
        }
        
        else if (!success) && (flag == 0) //checks if the angel has not reached the last row nor is in contact with obstacle
        {
            img = UIImage(named:"angel.png")
            self.backgroundColor = UIColor.cyanColor()
            success = false
        }
        else
        {
    
            if(success) && (flag == 0) // checks if the angel is in last row and not in contact with any obstacle
            {
                img = UIImage(named:"face_angel.png")
                self.backgroundColor = UIColor.purpleColor()
                success = false
            }
            
        }
       
        img!.drawInRect(imageRect)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchRow, touchCol : Int
        var xy : CGPoint
        
        print( "touchesBegan:withEvent:" )
        super.touchesBegan(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            self.inMotion = (self.row == touchRow  &&  self.col == touchCol)
            print( "touch point (x,y) = (\(self.x),\(self.y))" )
            print(self.inMotion)
            print( "  falls in cell (\(touchRow),\(touchCol))" )
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchRow, touchCol : Int
        var xy : CGPoint
        
        print( "touchesMoved:withEvent:" )
        super.touchesMoved(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            print( "touch point (x,y) = (\(self.x),\(self.y))" )
            print( "  falls in cell (\(touchRow),\(touchCol))" )
            
            for obs_point in self.obstaclePointsList{
                
                if((touchRow == Int(obs_point.x) && touchCol == Int(obs_point.y))) // checks if the angel touches obstacles 
                                                                                  // and sets the flags accordingly
                {
                    flag = 1
                    success = false
                    break;
                }
                
            }
            if(flag == 0) && (touchCol != 9) // checks for setting the angel face if its not met with obstacle or if it
                                             // has not reached the last row in either case the image changes
            {
                angel_flag = 1
                success = false
            }
            if(touchCol == 9)  // checks when the angel reaches the last row successfully and sets the respective flags
                
            {
                success = true
                
            }
            
            if self.inMotion {
                self.setNeedsDisplay()   // request view re-draw
            }
      }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print( "touchesEnded:withEvent:" )
        super.touchesEnded(touches, withEvent: event)
        if self.inMotion {
            var touchRow : Int = 0;  var touchCol : Int = 0
            var xy : CGPoint
            
            for t in touches {
                xy = t.locationInView(self)
                self.x = xy.x;  self.y = xy.y
                touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
                print( "touch point (x,y) = (\(self.x),\(self.y))" )
                print( "  falls in cell (\(touchRow),\(touchCol))" )
            }
            self.inMotion = false
            self.row = touchRow;  self.col = touchCol
            var flag_ = 0 //checks if the angel is touched the obstacle
            for obs_point in self.obstaclePointsList{
                
                if((self.row == Int(obs_point.x) && self.col == Int(obs_point.y))) // condition that checks if the angel has touched the obstacle
                {
                    self.backgroundColor = UIColor.redColor()
                    flag = 1
                    flag_ = 1
                    
                }
            }

            if(flag_ == 0){ // sets background color and flags when angel is not touched obstacle or even reached  the bottom                row
                self.backgroundColor = UIColor.cyanColor()
                angel_flag = 1
                flag  = 0 
            }
            self.backgroundColor = flag_ == 1 ? UIColor.redColor(): UIColor.cyanColor()
            
            if(flag_ != 1 && self.col == 9) // checks if the angel has reached last row successfully
            {
                self.backgroundColor = UIColor.purpleColor()
                success = true
            }
            self.setNeedsDisplay()
        }
    }
    
    
//    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print( "touchesCancelled:withEvent:" )
//        super.touchesCancelled(touches, withEvent: event)
//    }

}
