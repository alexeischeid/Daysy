//
//  DaysyItems.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/13/23.
//

import Foundation
import UserNotifications
import AVFoundation
import OpenAI

let defaults = UserDefaults.standard
let encoder = JSONEncoder()
let decoder = JSONDecoder()
let domain = Bundle.main.bundleIdentifier!
let notificationCenter = UNUserNotificationCenter.current()
let calendar = Calendar.current

let suggestedIcons: [String] = ["Suggested Icons"] + mostUsedIcons().prefix(5)

let animation = LoadingIndicator.LoadingAnimation.self
let sizes = LoadingIndicator.Size.allCases
let speeds = LoadingIndicator.Speed.allCases

let openAI: OpenAIProtocol = OpenAI(apiToken: apiKey) as OpenAIProtocol
var imageStore: ImageStore = ImageStore(openAIClient: openAI)
var speechStore: SpeechStore = SpeechStore(openAIClient: openAI)

let model = MobileNetV2()

let fileManager = FileManager.default
let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

let voices: [[String]] = [
    ["ar-SA", "Maged", "com.apple.ttsbundle.Maged-compact"],
    ["cs-CZ", "Zuzana", "com.apple.ttsbundle.Zuzana-compact"],
    ["da-DK", "Sara", "com.apple.ttsbundle.Sara-compact"],
    ["de-DE", "Anna", "com.apple.ttsbundle.Anna-compact"],
    ["de-DE", "Helena", "com.apple.ttsbundle.siri_female_de-DE_compact"],
    ["de-DE", "Martin", "com.apple.ttsbundle.siri_male_de-DE_compact"],
    ["el-GR", "Melina", "com.apple.ttsbundle.Melina-compact"],
    ["en-AU", "Catherine", "com.apple.ttsbundle.siri_female_en-AU_compact"],
    ["en-AU", "Gordon", "com.apple.ttsbundle.siri_male_en-AU_compact"],
    ["en-AU", "Karen", "com.apple.ttsbundle.Karen-compact"],
    ["en-GB", "Arthur", "com.apple.ttsbundle.siri_male_en-GB_compact"],
    ["en-GB", "Daniel", "com.apple.ttsbundle.Daniel-compact"],
    ["en-GB", "Martha", "com.apple.ttsbundle.siri_female_en-GB_compact"],
    ["en-IE", "Moira", "com.apple.ttsbundle.Moira-compact"],
    ["en-IN", "Rishi", "com.apple.ttsbundle.Rishi-compact"],
    ["en-US", "Aaron", "com.apple.ttsbundle.siri_male_en-US_compact"],
    ["en-US", "Fred", "com.apple.speech.synthesis.voice.Fred"],
    ["en-US", "Nicky", "com.apple.ttsbundle.siri_female_en-US_compact"],
    ["en-US", "Samantha", "com.apple.ttsbundle.Samantha-compact"],
    ["en-ZA", "Tessa", "com.apple.ttsbundle.Tessa-compact"],
    ["es-ES", "Mónica", "com.apple.ttsbundle.Monica-compact"],
    ["es-MX", "Paulina", "com.apple.ttsbundle.Paulina-compact"],
    ["fi-FI", "Satu", "com.apple.ttsbundle.Satu-compact"],
    ["fr-CA", "Amélie", "com.apple.ttsbundle.Amelie-compact"],
    ["fr-FR", "Daniel", "com.apple.ttsbundle.siri_male_fr-FR_compact"],
    ["fr-FR", "Marie", "com.apple.ttsbundle.siri_female_fr-FR_compact"],
    ["fr-FR", "Thomas", "com.apple.ttsbundle.Thomas-compact"],
    ["he-IL", "Carmit", "com.apple.ttsbundle.Carmit-compact"],
    ["hi-IN", "Lekha", "com.apple.ttsbundle.Lekha-compact"],
    ["hu-HU", "Mariska", "com.apple.ttsbundle.Mariska-compact"],
    ["id-ID", "Damayanti", "com.apple.ttsbundle.Damayanti-compact"],
    ["it-IT", "Alice", "com.apple.ttsbundle.Alice-compact"],
    ["ja-JP", "Hattori", "com.apple.ttsbundle.siri_male_ja-JP_compact"],
    ["ja-JP", "Kyoko", "com.apple.ttsbundle.Kyoko-compact"],
    ["ja-JP", "O-ren", "com.apple.ttsbundle.siri_female_ja-JP_compact"],
    ["ko-KR", "Yuna", "com.apple.ttsbundle.Yuna-compact"],
    ["nl-BE", "Ellen", "com.apple.ttsbundle.Ellen-compact"],
    ["nl-NL", "Xander", "com.apple.ttsbundle.Xander-compact"],
    ["no-NO", "Nora", "com.apple.ttabundle.Nora-compact"],
    ["pl-PL", "Zosia", "com.apple.ttsbundle.Zosia-compact"],
    ["pt-BR", "Luciana", "com.apple.ttsbundle.Luciana-compact"],
    ["pt-PT", "Joana", "com.apple.ttsbundle.Joana-compact"],
    ["ro-RO", "Ioana", "com.apple.ttsbundle.Ioana-compact"],
    ["ru-RU", "Milena", "com.apple.ttsbundle.Milena-compact"],
    ["sk-SK", "Laura", "com.apple.ttsbundle.Laura-compact"],
    ["sv-SE", "Alva", "com.apple.ttsbundle.Alva-compact"],
    ["th-TH", "Kanya", "com.apple.ttsbundle.Kanya-compact"],
    ["tr-TR", "Yelda", "com.apple.ttsbundle.Yelda-compact"],
    ["zh-CN", "Li-mu", "com.apple.ttsbundle.siri_male_zh-CN_compact"],
    ["zh-CN", "Tian-Tian", "com.apple.ttsbundle.Ting-Ting-compact"],
    ["zh-CN", "Yu-shu", "com.apple.ttsbundle.siri_female_zh-CN_compact"],
    ["zh-HK", "Sin-Ji", "com.apple.ttsbundle.Sin-Ji-compact"],
    ["zh-TW", "Mei-Jia", "com.apple.ttsbundle.Mei-Jia-compact"],
    ]

let languageNames: [String: String] = [
    "ar-SA": "Arabic (Saudi Arabia)",
    "cs-CZ": "Czech (Czech Republic)",
    "da-DK": "Danish (Denmark)",
    "de-DE": "German (Germany)",
    "el-GR": "Greek (Greece)",
    "en-AU": "English (Australia)",
    "en-GB": "English (United Kingdom)",
    "en-IE": "English (Ireland)",
    "en-IN": "English (India)",
    "en-US": "English (United States)",
    "en-ZA": "English (South Africa)",
    "es-ES": "Spanish (Spain)",
    "es-MX": "Spanish (Mexico)",
    "fi-FI": "Finnish (Finland)",
    "fr-CA": "French (Canada)",
    "fr-FR": "French (France)",
    "he-IL": "Hebrew (Israel)",
    "hi-IN": "Hindi (India)",
    "hu-HU": "Hungarian (Hungary)",
    "id-ID": "Indonesian (Indonesia)",
    "it-IT": "Italian (Italy)",
    "ja-JP": "Japanese (Japan)",
    "ko-KR": "Korean (South Korea)",
    "nl-BE": "Dutch (Belgium)",
    "nl-NL": "Dutch (Netherlands)",
    "no-NO": "Norwegian (Norway)",
    "pl-PL": "Polish (Poland)",
    "pt-BR": "Portuguese (Brazil)",
    "pt-PT": "Portuguese (Portugal)",
    "ro-RO": "Romanian (Romania)",
    "ru-RU": "Russian (Russia)",
    "sk-SK": "Slovak (Slovakia)",
    "sv-SE": "Swedish (Sweden)",
    "th-TH": "Thai (Thailand)",
    "tr-TR": "Turkish (Turkey)",
    "zh-CN": "Chinese (China)",
    "zh-HK": "Chinese (Hong Kong)",
    "zh-TW": "Chinese (Taiwan)"
]


let activities: [String] = ["Activities", "acousticguitar", "airplane", "ball", "bath", "bathtime", "blowing", "bus", "children", "clap", "climbing", "climbtree", "dancing", "drawing", "drum", "drumandcymbal", "drumsticks", "firetruck", "friends", "geography", "gettingdressed", "gift", "gifts", "halloween", "hide", "highfive", "horse", "jumpontrampoline", "listening", "look", "monkeybars", "motorcycle", "notebook", "playatbeach", "playcymbal", "playdrum", "playground", "playguitar", "playing", "playkeyboard", "playrecorder", "playvideogame", "puzzle", "quietmouth", "rideincar", "rideon", "sandbox", "singing", "sit", "sitcrisscross", "sitdown", "slide", "swing", "teacher", "television", "throwing", "tiesshoes", "time-out-corner", "time-out-floor", "timeout", "train", "trampoline", "walk", "watchingtv", "watchtv", "wave", "winner", "yawn"]

let school: [String] = ["School", "backpack", "books", "bus", "calendar", "classroom", "drawing", "geography", "history", "listen", "listening", "math", "notebook", "pencil", "quietmouth", "school", "science", "scissors", "sitcrisscross", "students", "teacher"]

let emotions: [String] = ["Emotions", "angry", "calmdown", "excited", "happy", "hide", "mad", "scared", "stubborn", "surprised", "wave", "wink", "yawn", "yeah", "yikes", "yucky"]

let bodyParts: [String] = ["Body Parts", "back", "backache", "blownose", "bra", "brushhair", "brushteeth", "chew", "climbing", "climbtree", "clipnails", "cold", "crying", "elbow", "eyes", "feet", "foot", "haircut", "hairpulling", "hand", "hands", "headache", "heart", "knee", "listen", "owie", "pullinghair", "sick", "smell", "sneeze", "teeth", "thinking", "wipeface", "wipenose", "yawn"]

let clothing: [String] = ["Clothing", "backpack", "baseballcap", "belt", "boots", "bra", "pants", "panties", "shirton", "shoeson", "shorts", "socks", "underwear"]

let food: [String] = ["Food and Drink", "allgone", "apple", "applejuice", "bacon", "bagel", "banana", "bananas", "birthdaycake", "blackberry", "cheeseburger", "cheeseslice", "cheesewedge", "chew", "chickennuggets", "chips", "corndog", "cupcake", "doughnut", "friedegg", "grapes", "grilledcheese", "icecreamcone", "icecreamsundae", "lemon", "lollipop", "loafofbread", "muffin", "orange", "orangejuice", "pan", "pancakes", "pastasauce", "peanutbutter", "peanutbutterbread", "pear", "pie", "pineapple", "pizza", "pizzaslice", "popcorn", "pretzel", "raisins", "rasberry", "sandwhich", "soda", "sodacan", "spoon", "strawberry", "sugar", "waffles", "water", "watermelon"]

let seasonsTime: [String] = ["Seasons and Time", "january", "february", "march", "april", "june", "july", "august", "september", "october", "november", "december", "morning", "afternoon", "evening", "winter", "spring", "summer", "fall", "1oclock", "2oclock", "3oclock", "4oclock", "5oclock", "6oclock", "7oclock", "8oclock", "9oclock", "10oclock", "11oclock", "12oclock"]

let vehicles: [String] = ["Vehicles", "airplane", "ambulance", "bike", "bus", "sportscar", "firetruck", "limo", "minivan", "motorcycle", "pickuptruck", "policecar", "semitruck", "tank", "train", "van"]

let nature: [String] = ["Nature", "apple", "applejuice", "axe", "banana", "cat", "christmas", "christmastree", "cow", "dog", "duck", "fall", "fish", "goat", "grapes", "halloween", "lemon", "morning", "orange", "pear", "pineapple", "pumpkin", "rasberry", "spring", "strawberry", "summer", "swan", "turtle", "watermelon", "winter", "woodclamp"]


let allPECS: [String] = ["All Icons", "1oclock", "2oclock", "3oclock", "4oclock", "5oclock", "6oclock", "7oclock", "8oclock", "9oclock", "10oclock", "11oclock", "12oclock", "a", "lowercase-a", "acousticguitar", "afternoon", "airplane", "allgone", "ambulance", "angry", "apple", "applejuice", "april", "august", "axe", "b", "lowercase-b", "back", "backache", "backpack", "bacon", "badsmell", "bagel", "ball", "banana", "bananas", "baseballcap", "bat", "bath", "bathtime", "belt", "bible", "bike", "birthdaycake", "biting", "blackberry", "blowing", "blownose", "books", "boots", "bottledwater", "bowl", "bra", "brownie", "brushhair", "brushteeth", "bubbles", "bus", "butterknife", "c", "lowercase-c", "calendar", "calmdown", "cat", "chair", "cheeseburger", "cheeseslice", "cheesewedge", "chest", "chew", "chickennuggets", "children", "chips", "choppingknife", "christmas", "christmastree", "church", "circle", "clap", "classroom", "cleanears", "cleanup", "clearears", "cleats", "climbing", "climbtree", "clipnails", "clotheshanger", "cold", "comb", "congratulations", "cooking", "corndog", "cottonswab", "couch", "cow", "cracker", "crying", "cupcake", "cymbal", "d", "lowercase-d", "dancing", "day", "december", "dentist", "dentistoffice", "deodorant", "dime", "doctor", "dog", "donttouch", "doughnut", "drawing", "drill", "drinking", "drinkingglass", "drive", "drum", "drumandcymbal", "drumsticks", "dryface", "duck", "e", "lowercase-e", "easter", "eat", "eatlunch", "elbow", "evening", "excited", "eye", "eyes", "f", "lowercase-f", "fall", "february", "feet", "firetruck", "fish", "fistbump", "foot", "fork", "frenchfries", "friedegg", "friends", "g", "lowercase-g", "geography", "gettingdressed", "gift", "gifts", "giraffe", "glue", "goat", "godownstairs", "goodbye", "goodjob", "goupstairs", "grapes", "grilledcheese", "h", "lowercase-h", "haircut", "hairdryer", "hairpulling", "halloween", "ham", "hammer", "hand", "hands", "happy", "hardboiledegg", "headache", "heart", "hello", "hide", "highfive", "history", "hitting", "horse", "hotdog", "hotdrink", "hotstove", "householdcleaner", "hug", "i", "lowercase-i", "icecreamcone", "icecreamsundae", "idea", "idontknow", "iwant", "j", "lowercase-j", "january", "july", "jumping", "jumpontrampoline", "june", "k", "lowercase-k", "ketchup", "keyboard", "kicking", "knee", "l", "lowercase-l", "lemon", "lightbulb", "limo", "listen", "listening", "loafofbread", "lollipop", "look", "lunch", "m", "lowercase-m", "mad", "man", "march", "math", "may", "men", "microphone", "milk", "minivan", "monkeybars", "morning", "motorcycle", "muffin", "mustard", "n", "lowercase-n", "nailclippers", "nickel", "nobiting", "nobitingnails", "noclimbing", "nohairpulling", "nohitting", "nojumping", "nokicking", "noon", "nopickingnose", "nopointing", "nopullinghair", "nopunching", "noscratching", "nosuckingthumb", "notebook", "nothrowing", "november", "nurse", "o", "lowercase-o", "october", "ok", "orange", "orangejuice", "oval", "owie", "p", "lowercase-p", "pan", "pancakes", "panties", "pants", "pantson", "paper", "papertowel", "park", "parrot", "pastasauce", "peace", "peanutbutter", "peanutbutterbread", "pear", "pen", "pencil", "penguin", "penny", "people", "petdog", "pick", "pickaxe", "pickingnose", "pickuptruck", "pie", "pig", "pineapple", "pitcher", "pizza", "pizzaslice", "playatbeach", "playcymbal", "playdrum", "playground", "playguitar", "playing", "playkeyboard", "playrecorder", "playvideogame", "please", "pliers", "pointing", "policecar", "policeman", "popcorn", "pot", "pretzel", "proud", "pullinghair", "pumpkin", "punching", "putbackpackon", "putinbackpack", "putondeodorant", "putsockson", "putstarontree", "puzzle", "q", "lowercase-q", "quarter", "quietmouth", "r", "lowercase-r", "raisins", "rasberry", "recorder", "rectangle", "refrigerator", "rideincar", "rideon", "rv", "s", "lowercase-s", "sacklunch", "sad", "sandbox", "sandwhich", "saw", "scared", "school", "science", "scissors", "scratching", "screwdriver", "seal", "semitruck", "september", "shakehands", "shark", "shirt", "shirton", "shoeson", "shorts", "shoulder", "shovel", "sick", "singing", "sit", "sitcrisscross", "sitdown", "sleep", "slide", "smell", "snake", "snapfingers", "sneakers", "sneeze", "snowplow", "soap", "socialstudies", "socks", "soda", "sodacan", "spoolofthread", "spoon", "sportscar", "spring", "square", "star", "steakknife", "stethoscope", "stocking", "stomachache", "stop", "stopsign", "stove", "strawberry", "stubborn", "students", "suckingthumb", "sugar", "summer", "sure", "surprised", "suv", "swan", "swing", "t", "lowercase-t", "tank", "teacher", "teddybear", "teeth", "television", "thanksgiving", "thinking", "thisone", "throwaway", "throwing", "tiesshoes", "timeout", "time-out-corner", "time-out-floor", "toast", "toaster", "toilet", "toiletopen", "toiletpaper", "toothbrush", "toothpasteclosed", "toothpasteopen", "touchhotstove", "toystore", "train", "trampoline", "trashcan", "trumpet", "turnoff", "turnon", "turtle", "tweezers", "u", "lowercase-u", "underwear", "usetoothpaste", "v", "lowercase-v", "van", "w", "lowercase-w", "waffles", "wagon", "wait", "walk", "washhands", "watchingtv", "watchtv", "water", "waterfountain", "watermelon", "wave", "week", "wink", "winner", "winter", "wintercoat", "wipeface", "wipenose", "woman", "women", "woodclamp", "wreath", "wrench", "x", "lowercase-x", "y", "lowercase-y", "yawn", "yeah", "yikes", "yucky", "yummy", "z", "lowercase-z", "zipper", "zipup"]


let pecsCategories: [[String]] = [activities, school, emotions, bodyParts, clothing,  food, seasonsTime, vehicles, nature, allPECS]
    
    let defaultCommunicationBoard: [[String]] = customPECSToBoard() + [["Activities", "acousticguitar", "airplane", "ball", "bath", "bathtime", "blowing", "bus", "children", "clap", "climbing", "climbtree", "dancing", "drawing", "drum", "drumandcymbal", "drumsticks", "firetruck", "friends", "geography", "gettingdressed", "gift", "gifts", "halloween", "hide", "highfive", "horse", "jumpontrampoline", "listening", "look", "monkeybars", "motorcycle", "notebook", "playatbeach", "playcymbal", "playdrum", "playground", "playguitar", "playing", "playkeyboard", "playrecorder", "playvideogame", "puzzle", "quietmouth", "rideincar", "rideon", "sandbox", "singing", "sit", "sitcrisscross", "sitdown", "slide", "swing", "teacher", "television", "throwing", "tiesshoes", "time-out-corner", "time-out-floor", "timeout", "train", "trampoline", "walk", "watchingtv", "watchtv", "wave", "winner", "yawn"],
                                                 ["School", "backpack", "books", "bus", "calendar", "classroom", "drawing", "geography", "history", "listen", "listening", "math", "notebook", "pencil", "quietmouth", "school", "science", "scissors", "sitcrisscross", "students", "teacher"],
                                                 ["Emotions", "angry", "calmdown", "excited", "happy", "hide", "mad", "scared", "stubborn", "surprised", "wave", "wink", "yawn", "yeah", "yikes", "yucky"],
                                                 ["Body Parts", "back", "backache", "blownose", "bra", "brushhair", "brushteeth", "chew", "climbing", "climbtree", "clipnails", "cold", "crying", "elbow", "eyes", "feet", "foot", "haircut", "hairpulling", "hand", "hands", "headache", "heart", "knee", "listen", "owie", "pullinghair", "sick", "smell", "sneeze", "teeth", "thinking", "wipeface", "wipenose", "yawn"],
                                                 ["Clothing", "backpack", "baseballcap", "belt", "boots", "bra", "pants", "panties", "shirton", "shoeson", "shorts", "socks", "underwear"],
                                                 ["Food and Drink", "allgone", "apple", "applejuice", "bacon", "bagel", "banana", "bananas", "birthdaycake", "blackberry", "cheeseburger", "cheeseslice", "cheesewedge", "chew", "chickennuggets", "chips", "corndog", "cupcake", "doughnut", "friedegg", "grapes", "grilledcheese", "icecreamcone", "icecreamsundae", "lemon", "lollipop", "loafofbread", "muffin", "orange", "orangejuice", "pan", "pancakes", "pastasauce", "peanutbutter", "peanutbutterbread", "pear", "pie", "pineapple", "pizza", "pizzaslice", "popcorn", "pretzel", "raisins", "rasberry", "sandwhich", "soda", "sodacan", "spoon", "strawberry", "sugar", "waffles", "water", "watermelon"],
                                                 ["Seasons and Time", "january", "february", "march", "april", "june", "july", "august", "september", "october", "november", "december", "morning", "afternoon", "evening", "winter", "spring", "summer", "fall", "1oclock", "2oclock", "3oclock", "4oclock", "5oclock", "6oclock", "7oclock", "8oclock", "9oclock", "10oclock", "11oclock", "12oclock"],
                                                 ["Vehicles", "airplane", "ambulance", "bike", "bus", "sportscar", "firetruck", "limo", "minivan", "motorcycle", "pickuptruck", "policecar", "semitruck", "tank", "train", "van"],
                                                 ["Nature", "apple", "applejuice", "axe", "banana", "cat", "christmas", "christmastree", "cow", "dog", "duck", "fall", "fish", "goat", "grapes", "halloween", "lemon", "morning", "orange", "pear", "pineapple", "pumpkin", "rasberry", "spring", "strawberry", "summer", "swan", "turtle", "watermelon", "winter", "woodclamp"],
                                                 
                                                 ["1oclock"], ["2oclock"], ["3oclock"], ["4oclock"], ["5oclock"], ["6oclock"], ["7oclock"], ["8oclock"], ["9oclock"], ["10oclock"], ["11oclock"], ["12oclock"], ["a"], ["lowercase-a"], ["acousticguitar"], ["afternoon"], ["airplane"], ["allgone"], ["ambulance"], ["angry"], ["apple"], ["applejuice"], ["april"], ["august"], ["axe"], ["b"], ["lowercase-b"], ["back"], ["backache"], ["backpack"], ["bacon"], ["badsmell"], ["bagel"], ["ball"], ["banana"], ["bananas"], ["baseballcap"], ["bat"], ["bath"], ["bathtime"], ["belt"], ["bible"], ["bike"], ["birthdaycake"], ["biting"], ["blackberry"], ["blowing"], ["blownose"], ["books"], ["boots"], ["bottledwater"], ["bowl"], ["bra"], ["brownie"], ["brushhair"], ["brushteeth"], ["bubbles"], ["bus"], ["butterknife"], ["c"], ["lowercase-c"], ["calendar"], ["calmdown"], ["cat"], ["chair"], ["cheeseburger"], ["cheeseslice"], ["cheesewedge"], ["chest"], ["chew"], ["chickennuggets"], ["children"], ["chips"], ["choppingknife"], ["christmas"], ["christmastree"], ["church"], ["circle"], ["clap"], ["classroom"], ["cleanears"], ["cleanup"], ["clearears"], ["cleats"], ["climbing"], ["climbtree"], ["clipnails"], ["clotheshanger"], ["cold"], ["comb"], ["congratulations"], ["cooking"], ["corndog"], ["cottonswab"], ["couch"], ["cow"], ["cracker"], ["crying"], ["cupcake"], ["cymbal"], ["d"], ["lowercase-d"], ["dancing"], ["day"], ["december"], ["dentist"], ["dentistoffice"], ["deodorant"], ["dime"], ["doctor"], ["dog"], ["donttouch"], ["doughnut"], ["drawing"], ["drill"], ["drinking"], ["drinkingglass"], ["drive"], ["drum"], ["drumandcymbal"], ["drumsticks"], ["dryface"], ["duck"], ["e"], ["lowercase-e"], ["easter"], ["eat"], ["eatlunch"], ["elbow"], ["evening"], ["excited"], ["eye"], ["eyes"], ["f"], ["lowercase-f"], ["fall"], ["february"], ["feet"], ["firetruck"], ["fish"], ["fistbump"], ["foot"], ["fork"], ["frenchfries"], ["friedegg"], ["friends"], ["g"], ["lowercase-g"], ["geography"], ["gettingdressed"], ["gift"], ["gifts"], ["giraffe"], ["glue"], ["goat"], ["godownstairs"], ["goodbye"], ["goodjob"], ["goupstairs"], ["grapes"], ["grilledcheese"], ["h"], ["lowercase-h"], ["haircut"], ["hairdryer"], ["hairpulling"], ["halloween"], ["ham"], ["hammer"], ["hand"], ["hands"], ["happy"], ["hardboiledegg"], ["headache"], ["heart"], ["hello"], ["hide"], ["highfive"], ["history"], ["hitting"], ["horse"], ["hotdog"], ["hotdrink"], ["hotstove"], ["householdcleaner"], ["hug"], ["i"], ["lowercase-i"], ["icecreamcone"], ["icecreamsundae"], ["idea"], ["idontknow"], ["iwant"], ["j"], ["lowercase-j"], ["january"], ["july"], ["jumping"], ["jumpontrampoline"], ["june"], ["k"], ["lowercase-k"], ["ketchup"], ["keyboard"], ["kicking"], ["knee"], ["l"], ["lowercase-l"], ["lemon"], ["lightbulb"], ["limo"], ["listen"], ["listening"], ["loafofbread"], ["lollipop"], ["look"], ["lunch"], ["m"], ["lowercase-m"], ["mad"], ["man"], ["march"], ["math"], ["may"], ["men"], ["microphone"], ["milk"], ["minivan"], ["monkeybars"], ["morning"], ["motorcycle"], ["muffin"], ["mustard"], ["n"], ["lowercase-n"], ["nailclippers"], ["nickel"], ["nobiting"], ["nobitingnails"], ["noclimbing"], ["nohairpulling"], ["nohitting"], ["nojumping"], ["nokicking"], ["noon"], ["nopickingnose"], ["nopointing"], ["nopullinghair"], ["nopunching"], ["noscratching"], ["nosuckingthumb"], ["notebook"], ["nothrowing"], ["november"], ["nurse"], ["o"], ["lowercase-o"], ["october"], ["ok"], ["orange"], ["orangejuice"], ["oval"], ["owie"], ["p"], ["lowercase-p"], ["pan"], ["pancakes"], ["panties"], ["pants"], ["pantson"], ["paper"], ["papertowel"], ["park"], ["parrot"], ["pastasauce"], ["peace"], ["peanutbutter"], ["peanutbutterbread"], ["pear"], ["pen"], ["pencil"], ["penguin"], ["penny"], ["people"], ["petdog"], ["pick"], ["pickaxe"], ["pickingnose"], ["pickuptruck"], ["pie"], ["pig"], ["pineapple"], ["pitcher"], ["pizza"], ["pizzaslice"], ["playatbeach"], ["playcymbal"], ["playdrum"], ["playground"], ["playguitar"], ["playing"], ["playkeyboard"], ["playrecorder"], ["playvideogame"], ["please"], ["pliers"], ["pointing"], ["policecar"], ["policeman"], ["popcorn"], ["pot"], ["pretzel"], ["proud"], ["pullinghair"], ["pumpkin"], ["punching"], ["putbackpackon"], ["putinbackpack"], ["putondeodorant"], ["putsockson"], ["putstarontree"], ["puzzle"], ["q"], ["lowercase-q"], ["quarter"], ["quietmouth"], ["r"], ["lowercase-r"], ["raisins"], ["rasberry"], ["recorder"], ["rectangle"], ["refrigerator"], ["rideincar"], ["rideon"], ["rv"], ["s"], ["lowercase-s"], ["sacklunch"], ["sad"], ["sandbox"], ["sandwhich"], ["saw"], ["scared"], ["school"], ["science"], ["scissors"], ["scratching"], ["screwdriver"], ["seal"], ["semitruck"], ["september"], ["shakehands"], ["shark"], ["shirt"], ["shirton"], ["shoeson"], ["shorts"], ["shoulder"], ["shovel"], ["sick"], ["singing"], ["sit"], ["sitcrisscross"], ["sitdown"], ["sleep"], ["slide"], ["smell"], ["snake"], ["snapfingers"], ["sneakers"], ["sneeze"], ["snowplow"], ["soap"], ["socialstudies"], ["socks"], ["soda"], ["sodacan"], ["spoolofthread"], ["spoon"], ["sportscar"], ["spring"], ["square"], ["star"], ["steakknife"], ["stethoscope"], ["stocking"], ["stomachache"], ["stop"], ["stopsign"], ["stove"], ["strawberry"], ["stubborn"], ["students"], ["suckingthumb"], ["sugar"], ["summer"], ["sure"], ["surprised"], ["suv"], ["swan"], ["swing"], ["t"], ["lowercase-t"], ["tank"], ["teacher"], ["teddybear"], ["teeth"], ["television"], ["thanksgiving"], ["thinking"], ["thisone"], ["throwaway"], ["throwing"], ["tiesshoes"], ["timeout"], ["time-out-corner"], ["time-out-floor"], ["toast"], ["toaster"], ["toilet"], ["toiletopen"], ["toiletpaper"], ["toothbrush"], ["toothpasteclosed"], ["toothpasteopen"], ["touchhotstove"], ["toystore"], ["train"], ["trampoline"], ["trashcan"], ["trumpet"], ["turnoff"], ["turnon"], ["turtle"], ["tweezers"], ["u"], ["lowercase-u"], ["underwear"], ["usetoothpaste"], ["v"], ["lowercase-v"], ["van"], ["w"], ["lowercase-w"], ["waffles"], ["wagon"], ["wait"], ["walk"], ["washhands"], ["watchingtv"], ["watchtv"], ["water"], ["waterfountain"], ["watermelon"], ["wave"], ["week"], ["wink"], ["winner"], ["winter"], ["wintercoat"], ["wipeface"], ["wipenose"], ["woman"], ["women"], ["woodclamp"], ["wreath"], ["wrench"], ["x"], ["lowercase-x"], ["y"], ["lowercase-y"], ["yawn"], ["yeah"], ["yikes"], ["yucky"], ["yummy"], ["z"], ["lowercase-z"], ["zipper"], ["zipup"]
    ]

