//
//  CardData.swift
//  NBCampStart
//
//  Created by 서동환 on 3/6/25.
//

import Foundation
import UIKit

struct CardData: Hashable {
    let uuid: UUID
    var studyImage: UIImage?  // 공부할 내용 이미지
    var resolution: String?  // 다짐
    var objective: String? // 학습 목표
    let date: Date  // 날짜
}
