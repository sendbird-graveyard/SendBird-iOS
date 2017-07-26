//
//  String+SendBird.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 7/26/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import Foundation

extension String {
    func urlencoding() -> String {
        var output: String = ""

        for thisChar in self.characters {
            if thisChar == " " {
                output += "+"
            }
            else if thisChar == "." ||
                thisChar == "-" ||
                thisChar == "_" ||
                thisChar == "~" ||
                (thisChar >= "a" && thisChar <= "z") ||
                (thisChar >= "A" && thisChar <= "Z") ||
                (thisChar >= "0" && thisChar <= "9") {
                let code = String(thisChar).utf8.map{ UInt8($0) }[0]
                output += String(format: "%c", code)
            }
            else {
                let code = String(thisChar).utf8.map{ UInt8($0) }[0]
                output += String(format: "%%%02X", code)
            }
        }
        
        return output;
    }
}
