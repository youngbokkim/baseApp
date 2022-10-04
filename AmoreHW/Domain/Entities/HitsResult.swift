//
//  HitsResult.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import Foundation

/**
 {
     total : 1350349,
     totalHits : 500,
     hits : [
         {
              id : 5555,
              webFormatURL : 이미지 경로,
              userImageURL : 이미지 경로,
              likes : 99,
              comments : 99
         },
         {
              id : 5556,
              webFormatURL : 이미지 경로,
              userImageURL : 이미지 경로,
              likes : 99,
              comments : 99
         }
     ]
 }
 */
struct HitsResult: Decodable {
    let total: Float
    let totalHits: Float
    let hits: [Hit]
}

struct Hit: Decodable {
    let id: Float
    let webformatURL: String
    let userImageURL: String
    let likes: Int
    let comments: Int
    let tags: String
    let type: String
    let user: String
}

extension Hit {
    func rootKey()-> String {
        return "\(id)/"
    }
}
