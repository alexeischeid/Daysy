//
//  DaysyItems.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/13/23.
//

import Foundation
import UserNotifications

let defaults = UserDefaults.standard
let encoder = JSONEncoder()
let decoder = JSONDecoder()
let domain = Bundle.main.bundleIdentifier!
let speechSynthesizer = CustomSpeechSynthesizer()
let notificationCenter = UNUserNotificationCenter.current()
let calendar = Calendar.current

let suggestedIcons: [String] = ["Suggested Icons"] + mostUsedIcons().prefix(5)


let seasonsTime: [String] = ["Seasons and Time",
                      "january",
                      "february",
                      "march",
                      "april",
                      "june",
                      "july",
                      "august",
                      "september",
                      "october",
                      "november",
                      "december",
                      "morning",
                      "afternoon",
                      "evening",
                      "winter",
                      "spring",
                      "summer",
                      "fall",
                      "1oclock",
                      "2oclock",
                      "3oclock",
                      "4oclock",
                      "5oclock",
                      "6oclock",
                      "7oclock",
                      "8oclock",
                      "9oclock",
                      "10oclock",
                      "11oclock",
                      "12oclock"
                      ]
let activities: [String] = ["Activities", "acousticguitar", "airplane", "ball", "bath", "bathtime", "blowing", "bus", "children", "clap", "climbing", "climbtree", "dancing", "drawing", "drum", "drumandcymbal", "drumsticks", "firetruck", "friends", "geography", "gettingdressed", "gift", "gifts", "halloween", "hide", "highfive", "horse", "jumpontrampoline", "listening",
                            "look", "monkeybars", "motorcycle", "notebook", "playatbeach", "playcymbal", "playdrum", "playground",
                            "playguitar", "playing", "playkeyboard", "playrecorder", "playvideogame",
                            "puzzle", "quietmouth", "rideincar", "rideon", "sandbox", "singing", "sit",
                            "sitcrisscross", "sitdown", "slide", "swing", "teacher",
                            "television", "throwing", "tiesshoes", "time-out-corner",
                            "time-out-floor", "timeout", "train", "trampoline", "walk", "watchingtv", "watchtv",
                            "wave", "winner", "yawn"
                        ]
let emotions: [String] = ["Emotions", "angry", "calmdown", "excited", "happy", "hide", "mad", "scared",
                          "stubborn", "surprised", "wave", "wink", "yawn", "yeah", "yikes",
                          "yucky"
                      ]
let food: [String] = ["Food and Drink", "allgone", "apple", "applejuice", "bacon", "bagel", "banana",
                      "bananas", "birthdaycake", "blackberry", "cheeseburger", "cheeseslice",
                      "cheesewedge", "chew", "chickennuggets", "chips", "corndog", "cupcake",
                      "doughnut", "friedegg", "grapes", "grilledcheese", "icecreamcone",
                      "icecreamsundae", "lemon", "lollipop", "loafofbread", "muffin",
                      "orange", "orangejuice", "pan", "pancakes", "pastasauce", "peanutbutter",
                      "peanutbutterbread", "pear", "pie", "pineapple", "pizza", "pizzaslice",
                      "popcorn", "pretzel", "raisins", "rasberry", "sandwhich", "soda",
                      "sodacan", "spoon", "strawberry", "sugar", "waffles", "water",
                      "watermelon"
                  ]
let bodyParts: [String] = ["Body Parts", "back", "backache",
                        "blownose", "bra", "brushhair", "brushteeth",
                           "chew", "climbing", "climbtree", "clipnails", "cold",
                           "crying",
                           "elbow", "eyes", "feet", "foot", "haircut", "hairpulling", "hand",
                           "hands", "headache", "heart", "knee", "listen",
                        "owie", "pullinghair", "sick", "smell",
                           "sneeze", "teeth", "thinking",
                        "wipeface", "wipenose", "yawn"
                       ]
let vehicles: [String] = ["Vehicles", "airplane", "ambulance", "bike",
                          "bus", "sportscar", "firetruck", "limo", "minivan",
                          "motorcycle", "pickuptruck", "policecar", "semitruck",
                          "tank", "train", "van"]
let nature: [String] = ["Nature", "apple", "applejuice", "axe", "banana", "cat", "christmas", "christmastree", "cow", "dog", "duck", "fall", "fish", "goat", "grapes", "halloween", "lemon", "morning", "orange", "pear", "pineapple", "pumpkin", "rasberry", "spring", "strawberry", "summer", "swan", "turtle", "watermelon", "winter", "woodclamp"
]
let school: [String] = ["School", "backpack", "books", "bus", "calendar", "classroom", "drawing", "geography", "history", "listen", "listening", "math", "notebook", "pencil", "quietmouth", "school", "science", "scissors", "sitcrisscross", "students", "teacher"
]
let clothing: [String] = ["Clothing", "backpack", "baseballcap", "belt", "boots", "bra", "pants", "panties", "shirton", "shoeson", "shorts", "socks", "underwear"
]

let allPECS: [String] = ["All Icons", "1oclock", "2oclock", "3oclock", "4oclock", "5oclock", "6oclock", "7oclock", "8oclock", "9oclock", "10oclock", "11oclock", "12oclock", "a", "lowercase-a", "acousticguitar", "afternoon", "airplane", "allgone", "ambulance", "angry", "apple", "applejuice", "april", "august", "axe", "b", "lowercase-b", "back", "backache", "backpack", "bacon", "badsmell", "bagel", "ball", "banana", "bananas", "baseballcap", "bat", "bath", "bathtime", "belt", "bible", "bike", "birthdaycake", "biting", "blackberry", "blowing", "blownose", "books", "boots", "bottledwater", "bowl", "bra", "brownie", "brushhair", "brushteeth", "bubbles", "bus", "butterknife", "c", "lowercase-c", "calendar", "calmdown", "cat", "chair", "cheeseburger", "cheeseslice", "cheesewedge", "chest", "chew", "chickennuggets", "children", "chips", "choppingknife", "christmas", "christmastree", "church", "circle", "clap", "classroom", "cleanears", "cleanup", "clearears", "cleats", "climbing", "climbtree", "clipnails", "clotheshanger", "cold", "comb", "congratulations", "cooking", "corndog", "cottonswab", "couch", "cow", "cracker", "crying", "cupcake", "cymbal", "d", "lowercase-d", "dancing", "day", "december", "dentist", "dentistoffice", "deodorant", "dime", "doctor", "dog", "donttouch", "doughnut", "drawing", "drill", "drinking", "drinkingglass", "drive", "drum", "drumandcymbal", "drumsticks", "dryface", "duck", "e", "lowercase-e", "easter", "eat", "eatlunch", "elbow", "evening", "excited", "eye", "eyes", "f", "lowercase-f", "fall", "february", "feet", "firetruck", "fish", "fistbump", "foot", "fork", "frenchfries", "friedegg", "friends", "g", "lowercase-g", "geography", "gettingdressed", "gift", "gifts", "giraffe", "glue", "goat", "godownstairs", "goodbye", "goodjob", "goupstairs", "grapes", "grilledcheese", "h", "lowercase-h", "haircut", "hairdryer", "hairpulling", "halloween", "ham", "hammer", "hand", "hands", "happy", "hardboiledegg", "headache", "heart", "hello", "hide", "highfive", "history", "hitting", "horse", "hotdog", "hotdrink", "hotstove", "householdcleaner", "hug", "i", "lowercase-i", "icecreamcone", "icecreamsundae", "idea", "idontknow", "iwant", "j", "lowercase-j", "january", "july", "jumping", "jumpontrampoline", "june", "k", "lowercase-k", "ketchup", "keyboard", "kicking", "knee", "l", "lowercase-l", "lemon", "lightbulb", "limo", "listen", "listening", "loafofbread", "lollipop", "look", "lunch", "m", "lowercase-m", "mad", "man", "march", "math", "may", "men", "microphone", "milk", "minivan", "monkeybars", "morning", "motorcycle", "muffin", "mustard", "n", "lowercase-n", "nailclippers", "nickel", "nobiting", "nobitingnails", "noclimbing", "nohairpulling", "nohitting", "nojumping", "nokicking", "noon", "nopickingnose", "nopointing", "nopullinghair", "nopunching", "noscratching", "nosuckingthumb", "notebook", "nothrowing", "november", "nurse", "o", "lowercase-o", "october", "ok", "orange", "orangejuice", "oval", "owie", "p", "lowercase-p", "pan", "pancakes", "panties", "pants", "pantson", "paper", "papertowel", "park", "parrot", "pastasauce", "peace", "peanutbutter", "peanutbutterbread", "pear", "pen", "pencil", "penguin", "penny", "people", "petdog", "pick", "pickaxe", "pickingnose", "pickuptruck", "pie", "pig", "pineapple", "pitcher", "pizza", "pizzaslice", "playatbeach", "playcymbal", "playdrum", "playground", "playguitar", "playing", "playkeyboard", "playrecorder", "playvideogame", "please", "pliers", "pointing", "policecar", "policeman", "popcorn", "pot", "pretzel", "proud", "pullinghair", "pumpkin", "punching", "putbackpackon", "putinbackpack", "putondeodorant", "putsockson", "putstarontree", "puzzle", "q", "lowercase-q", "quarter", "quietmouth", "r", "lowercase-r", "raisins", "rasberry", "recorder", "rectangle", "refrigerator", "rideincar", "rideon", "rv", "s", "lowercase-s", "sacklunch", "sad", "sandbox", "sandwhich", "saw", "scared", "school", "science", "scissors", "scratching", "screwdriver", "seal", "semitruck", "september", "shakehands", "shark", "shirt", "shirton", "shoeson", "shorts", "shoulder", "shovel", "sick", "singing", "sit", "sitcrisscross", "sitdown", "sleep", "slide", "smell", "snake", "snapfingers", "sneakers", "sneeze", "snowplow", "soap", "socialstudies", "socks", "soda", "sodacan", "spoolofthread", "spoon", "sportscar", "spring", "square", "star", "steakknife", "stethoscope", "stocking", "stomachache", "stop", "stopsign", "stove", "strawberry", "stubborn", "students", "suckingthumb", "sugar", "summer", "sure", "surprised", "suv", "swan", "swing", "t", "lowercase-t", "tank", "teacher", "teddybear", "teeth", "television", "thanksgiving", "thinking", "thisone", "throwaway", "throwing", "tiesshoes", "timeout", "time-out-corner", "time-out-floor", "toast", "toaster", "toilet", "toiletopen", "toiletpaper", "toothbrush", "toothpasteclosed", "toothpasteopen", "touchhotstove", "toystore", "train", "trampoline", "trashcan", "trumpet", "turnoff", "turnon", "turtle", "tweezers", "u", "lowercase-u", "underwear", "usetoothpaste", "v", "lowercase-v", "van", "w", "lowercase-w", "waffles", "wagon", "wait", "walk", "washhands", "watchingtv", "watchtv", "water", "waterfountain", "watermelon", "wave", "week", "wink", "winner", "winter", "wintercoat", "wipeface", "wipenose", "woman", "women", "woodclamp", "wreath", "wrench", "x", "lowercase-x", "y", "lowercase-y", "yawn", "yeah", "yikes", "yucky", "yummy", "z", "lowercase-z", "zipper", "zipup"]


let pecsCategories: [[String]] = [activities, school, emotions, bodyParts, clothing,  food, seasonsTime, vehicles, nature, allPECS]
