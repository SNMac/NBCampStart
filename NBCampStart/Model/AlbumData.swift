//
//  AlbumData.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import Foundation
import UIKit

struct AlbumData {
    var studyImage: UIImage?  // 공부할 내용 이미지
    let date: Date = .now  // 날짜
    var resolution: String = ""  // 다짐
    var objective: String = "" // 학습 목표
}
