//
//  NSRailConnection.m
//  NSTimes
//
//  Created by Robert Dougan on 11/29/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "NSRailConnection.h"

#import "Train.h"

#import "DDXML.h"
#import "AFNetworking.h"
#import "TFHpple.h"

@implementation NSRailConnection

@synthesize from = _from,
to = _to;

@synthesize stations = _stations;

static NSRailConnection *sharedInstance = nil;

+ (NSRailConnection *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[NSRailConnection alloc] init];
        
        // Grab from userdefaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *defaultsTo = [userDefaults objectForKey:@"to"];
        NSString *defaultsFrom = [userDefaults objectForKey:@"from"];
        
        if (defaultsTo) {
            [sharedInstance setTo:defaultsTo];
        } else {
            [sharedInstance setTo:@"Amsterdam Centraal"];
        }
        
        if (defaultsFrom) {
            [sharedInstance setFrom:defaultsFrom];
        } else {
            [sharedInstance setFrom:@"Haarlem"];
        }
        
        [sharedInstance setStations:@[
            @[ @"Zwolle", @"52.5167747", @"6.083021899999949" ],
            @[ @"Zwijn`drecht", @"51.8203778", @"4.616301300000032" ],
            @[ @"Zwaagwesteinde", @"53.2578875", @"6.03714130000003" ],
            @[ @"Zutphen", @"52.139983", @"6.195501000000036" ],
            @[ @"Zuidhorn", @"53.2431482", @"6.4081043999999565" ],
            @[ @"Zuidbroek", @"53.1704058", @"6.862173100000064" ],
            @[ @"Zoetermeer Oost", @"52.0463905", @"4.492777799999999" ],
            @[ @"Zoetermeer", @"52.060669", @"4.494024999999965" ],
            @[ @"Zevenbergen", @"51.6452778", @"4.599722199999974" ],
            @[ @"Zevenaar", @"51.931478", @"6.074380000000019" ],
            @[ @"Zetten-Andelst", @"51.920056", @"5.722840799999972" ],
            @[ @"Zandvoort aan Zee", @"52.3752785", @"4.5327777999999626" ],
            @[ @"Zaltbommel", @"51.8071348", @"5.249574700000039" ],
            @[ @"Zaandam Kogerveld", @"52.456665", @"4.82027770000002" ],
            @[ @"Zaandam", @"52.4420399", @"4.829199199999948" ],
            @[ @"Wormerveer", @"52.497209", @"4.790000999999961" ],
            @[ @"Workum", @"52.98053299999999", @"5.447116000000051" ],
            @[ @"Wolvega", @"52.8761111", @"6.001388899999938" ],
            @[ @"Woerden", @"52.08788999999999", @"4.8851869999999735" ],
            @[ @"Woerden", @"52.08788999999999", @"4.8851869999999735" ],
            @[ @"Winterswijk West", @"51.971832", @"6.717772999999966" ],
            @[ @"Winterswijk", @"51.971832", @"6.717772999999966" ],
            @[ @"Winsum", @"53.3312", @"6.515700000000038" ],
            @[ @"Winschoten", @"53.14249840000001", @"7.036787699999991" ],
            @[ @"Wijhe", @"52.387959", @"6.135015199999998" ],
            @[ @"Wijchen", @"51.809501", @"5.730865999999992" ],
            @[ @"Wierden", @"52.3582599", @"6.5938730000000305" ],
            @[ @"Wezep", @"52.4609049", @"6.003018999999995" ],
            @[ @"Westervoort", @"51.961272", @"5.968919000000028" ],
            @[ @"Wehl", @"51.95964170000001", @"6.207727299999988" ],
            @[ @"Weesp", @"52.3080507", @"5.040621699999974" ],
            @[ @"Weert", @"51.2439415", @"5.714222199999995" ],
            @[ @"Warffum", @"53.393408", @"6.559259099999963" ],
            @[ @"Waddinxveen Noord", @"52.0550003", @"4.648333500000035" ],
            @[ @"Waddinxveen", @"52.047804", @"4.655489999999986" ],
            @[ @"Vught", @"51.653306", @"5.29434660000004" ],
            @[ @"Vroomshoop", @"52.4666667", @"6.566666700000042" ],
            @[ @"Vriezenveen", @"52.4085238", @"6.614630099999999" ],
            @[ @"Voorst-Empe", @"52.1575012", @"6.143610999999964" ],
            @[ @"Voorst-Empe", @"52.1575012", @"6.143610999999964" ],
            @[ @"Voorhout", @"52.2230556", @"4.486388900000065" ],
            @[ @"Voorhout", @"52.2230556", @"4.486388900000065" ],
            @[ @"Voorburg", @"52.070579", @"4.364675000000034" ],
            @[ @"Voerendaal", @"50.8791531", @"5.931160200000022" ],
            @[ @"Vlissingen Souburg", @"51.467957", @"3.605565599999977" ],
            @[ @"Vlissingen", @"51.4536672", @"3.570912499999963" ],
            @[ @"Vleuten", @"52.102901", @"5.015496999999982" ],
            @[ @"Vlaardingen West", @"51.907951", @"4.336365999999998" ],
            @[ @"Vlaardingen Oost", @"51.91027829999999", @"4.361666700000001" ],
            @[ @"Vlaardingen Centrum", @"51.9030571", @"4.344166800000039" ],
            @[ @"Vierlingsbeek", @"51.5964371", @"6.007143400000018" ],
            @[ @"Venray", @"51.5256257", @"5.9736992000000555" ],
            @[ @"Venlo", @"51.3704888", @"6.172386200000005" ],
            @[ @"Velp", @"51.9990669", @"5.985699000000068" ],
            @[ @"Veenwouden", @"53.238471", @"5.991469199999983" ],
            @[ @"Veenendaal-De Klomp", @"52.04583359999999", @"5.573888799999963" ],
            @[ @"Veenendaal West", @"52.0263009", @"5.554430899999943" ],
            @[ @"Veenendaal Centrum", @"52.02316", @"5.557800000000043" ],
            @[ @"Veendam", @"53.1062782", @"6.875099800000044" ],
            @[ @"Varsseveld", @"51.9435959", @"6.463053400000035" ],
            @[ @"Valkenburg", @"50.8652306", @"5.832051500000034" ],
            @[ @"Utrecht Zuilen", @"52.1107415", @"5.08714359999999" ],
            @[ @"Utrecht Terwijde", @"52.1077351", @"5.03678519999994" ],
            @[ @"Utrecht Overvecht", @"52.1179619", @"5.108037899999999" ],
            @[ @"Utrecht Maliebaan", @"52.0911588", @"5.132811800000013" ],
            @[ @"Utrecht Lunetten", @"52.06249", @"5.135472100000015" ],
            @[ @"Utrecht Centraal", @"52.089398", @"5.1098610000000235" ],
            @[ @"Usquert", @"53.404171", @"6.610838000000058" ],
            @[ @"Uithuizermeeden", @"53.4143783", @"6.725561700000071" ],
            @[ @"Uithuizen", @"53.4166667", @"6.666666699999951" ],
            @[ @"Uitgeest", @"52.530271", @"4.711218000000031" ],
            @[ @"Twello", @"52.24053199999999", @"6.101388000000043" ],
            @[ @"Tilburg Universiteit", @"51.5649986", @"5.051111200000037" ],
            @[ @"Tilburg Reeshof", @"51.5824998", @"4.997482600000012" ],
            @[ @"Tilburg", @"51.5862949", @"5.079127200000016" ],
            @[ @"Tiel Passewaaij", @"51.8660491", @"5.41677930000003" ],
            @[ @"Tiel", @"51.8876176", @"5.427876500000025" ],
            @[ @"Terborg", @"51.9202661", @"6.356025199999976" ],
            @[ @"Tegelen", @"51.3437209", @"6.137353599999983" ],
            @[ @"Swalmen", @"51.23105899999999", @"6.037361000000033" ],
            @[ @"Susteren", @"51.0640999", @"5.852744799999982" ],
            @[ @"Steenwijk", @"52.7868939", @"6.118068600000015" ],
            @[ @"Stedum", @"52.2703956", @"10.109747800000036" ],
            @[ @"Stavoren", @"52.88233899999999", @"5.366146999999955" ],
            @[ @"Spaubeek", @"50.9348612", @"5.842850099999964" ],
            @[ @"Soestdijk", @"52.1912612", @"5.286415199999965" ],
            @[ @"Soest Zuid", @"52.160428", @"5.303247300000066" ],
            @[ @"Sneek Noord", @"53.0409319", @"5.663180799999964" ],
            @[ @"Sneek", @"53.0337476", @"5.655647300000055" ],
            @[ @"Sliedrecht Baanhoek", @"51.82496889999999", @"4.749240800000052" ],
            @[ @"Sliedrecht", @"51.8248681", @"4.7731624000000465" ],
            @[ @"Sittard", @"50.9984052", @"5.869118599999979" ],
            @[ @"Schiphol", @"52.3080556", @"4.7641667000000325" ],
            @[ @"Schinnen", @"50.9436467", @"5.8793607000000065" ],
            @[ @"Schin op Geul", @"50.851629", @"5.869504000000006" ],
            @[ @"Schiedam Nieuwland", @"51.9172117", @"4.385032899999942" ],
            @[ @"Schiedam Centrum", @"51.9219437", @"4.409999800000037" ],
            @[ @"Scheemda", @"53.1666667", @"6.966666700000019" ],
            @[ @"Schagen", @"52.787747", @"4.797933999999941" ],
            @[ @"Sauwerd", @"53.294304", @"6.5328391000000465" ],
            @[ @"Sassenheim", @"52.2246479", @"4.520049800000038" ],
            @[ @"Sappemeer Oost", @"53.1589183", @"6.7955647999999655" ],
            @[ @"Santpoort Zuid", @"52.419708", @"4.630381499999999" ],
            @[ @"Santpoort Noord", @"52.4336897", @"4.644068100000027" ],
            @[ @"Ruurlo", @"52.08160299999999", @"6.4548904000000675" ],
            @[ @"Rotterdam Zuidplein", @"51.8870767", @"4.490021699999943" ],
            @[ @"Rotterdam Zuid", @"51.9044456", @"4.5102776999999605" ],
            @[ @"Rotterdam Stadion", @"51.8938904", @"4.519722000000002" ],
            @[ @"Rotterdam Noord", @"51.93192879999999", @"4.459927099999959" ],
            @[ @"Rotterdam Lombardijen", @"51.87381490000001", @"4.525179900000012" ],
            @[ @"Rotterdam Centraal", @"51.9254045", @"4.469494299999951" ],
            @[ @"Rotterdam Blaak", @"51.9189894", @"4.486408399999959" ],
            @[ @"Rotterdam Alexander", @"51.9519463", @"4.553611300000057" ],
            @[ @"Rosmalen", @"51.7166667", @"5.366666699999996" ],
            @[ @"Roosendaal", @"51.5321349", @"4.461994000000004" ],
            @[ @"Roodeschool", @"53.419683", @"6.7741660000000365" ],
            @[ @"Roermond", @"51.192442", @"5.994694999999979" ],
            @[ @"Rilland-Bath", @"51.4227791", @"4.16111090000004" ],
            @[ @"Rijswijk", @"52.0319447", @"4.317688500000031" ],
            @[ @"Rijssen", @"52.3", @"6.516666699999973" ],
            @[ @"Rhenen", @"51.96213969999999", @"5.571115500000019" ],
            @[ @"Rheden", @"52.0057368", @"6.027959399999986" ],
            @[ @"Reuver", @"51.2862173", @"6.082822599999986" ],
            @[ @"Ravenstein", @"49.4122515", @"9.518587199999956" ],
            @[ @"Raalte", @"52.3798566", @"6.286236599999938" ],
            @[ @"Putten", @"52.25867599999999", @"5.605372699999975" ],
            @[ @"Purmerend Weidevenne", @"52.49666620000001", @"4.927730600000018" ],
            @[ @"Purmerend Overwhere", @"52.514788", @"4.964871899999935" ],
            @[ @"Purmerend", @"52.5143815", @"4.964061099999981" ],
            @[ @"Overveen", @"52.3911095", @"4.606111" ],
            @[ @"Oudenbosch", @"51.5832716", @"4.5275943000000325" ],
            @[ @"Oss West", @"51.7580566", @"5.50555559999998" ],
            @[ @"Oss", @"51.764377", @"5.514620000000036" ],
            @[ @"Opheusden", @"51.9333333", @"5.62972220000006" ],
            @[ @"Oosterbeek", @"51.9858013", @"5.846281299999987" ],
            @[ @"Ommen", @"52.5248059", @"6.426292600000011" ],
            @[ @"Olst", @"52.3333333", @"6.116666699999996" ],
            @[ @"Oldenzaal", @"52.3116551", @"6.926828300000011" ],
            @[ @"Oisterwijk", @"51.5788944", @"5.192409999999995" ],
            @[ @"Obdam", @"52.6760192", @"4.908188300000006" ],
            @[ @"Nuth", @"50.91619859999999", @"5.8784286000000066" ],
            @[ @"Nunspeet", @"52.3765849", @"5.784118000000035" ],
            @[ @"Nijverdal West", @"52.363755", @"6.463265999999976" ],
            @[ @"Nijverdal", @"52.363755", @"6.463265999999976" ],
            @[ @"Nijmegen Lent", @"51.8596385", @"5.865880899999979" ],
            @[ @"Nijmegen Heyendaal", @"51.8197808", @"5.862201599999935" ],
            @[ @"Nijmegen Dukenburg", @"51.8125", @"5.795833300000027" ],
            @[ @"Nijmegen", @"51.842867", @"5.854622000000063" ],
            @[ @"Nijkerk", @"52.2224835", @"5.483562500000062" ],
            @[ @"Nieuweschans", @"53.1804651", @"7.207318100000066" ],
            @[ @"Nieuw Amsterdam", @"52.7145064", @"6.863239000000021" ],
            @[ @"Naarden-Bussum", @"52.2737893", @"5.166387100000065" ],
            @[ @"Middelburg", @"51.5", @"3.616666699999996" ],
            @[ @"Meppel", @"52.697361", @"6.197333999999955" ],
            @[ @"Meerssen", @"50.8849427", @"5.752636700000039" ],
            @[ @"Martenshoek", @"53.1633007", @"6.731162700000027" ],
            @[ @"Mariënberg", @"50.6503661", @"13.1622883" ],
            @[ @"Mantgum", @"53.127671", @"5.721147999999971" ],
            @[ @"Maastricht Randwyck", @"50.83396949999999", @"5.709566499999937" ],
            @[ @"Maastricht", @"50.8513682", @"5.6909725000000435" ],
            @[ @"Maassluis West", @"51.9226067", @"4.254565599999978" ],
            @[ @"Maassluis", @"51.9226067", @"4.254565599999978" ],
            @[ @"Maarssen", @"52.1416553", @"5.045667900000012" ],
            @[ @"Maarn", @"52.065812", @"5.369318000000021" ],
            @[ @"Maarheeze", @"51.315833", @"5.611521000000039" ],
            @[ @"Lunteren", @"52.0882573", @"5.617300600000021" ],
            @[ @"Loppersum", @"53.3316667", @"6.746944399999961" ],
            @[ @"Lochem", @"52.1614115", @"6.415598600000067" ],
            @[ @"Lichtenvoorde-Groenlo", @"51.98740309999999", @"6.569337200000064" ],
            @[ @"Lelystad Centrum", @"52.5077782", @"5.472777800000017" ],
            @[ @"Leiden Lammenschans", @"52.146946", @"4.492499800000019" ],
            @[ @"Leiden Centraal", @"52.166111", @"4.48166660000004" ],
            @[ @"Leeuwarden Camminghaburen", @"53.2119934", @"5.843056799999999" ],
            @[ @"Leeuwarden", @"53.2012334", @"5.799913300000071" ],
            @[ @"Leerdam", @"51.8943133", @"5.096927000000051" ],
            @[ @"Landgraaf", @"50.8927646", @"6.022408499999983" ],
            @[ @"Lage Zwaluwe", @"51.70805559999999", @"4.70333329999994" ],
            @[ @"Kruiningen-Yerseke", @"51.4650002", @"4.037222400000019" ],
            @[ @"Kropswolde", @"53.1424949", @"6.723131999999964" ],
            @[ @"Krommenie-Assendelft", @"52.5034775", @"4.7571695999999974" ],
            @[ @"Krabbendijke", @"51.4308295", @"4.112138500000015" ],
            @[ @"Koudum-Molkwerum", @"52.90281969999999", @"5.410691300000053" ],
            @[ @"Koog-Zaandijk", @"52.4740433", @"4.802817900000036" ],
            @[ @"Koog Bloemwijk", @"52.4586105", @"4.805555300000037" ],
            @[ @"Klarenbeek", @"52.1679389", @"6.069550100000015" ],
            @[ @"Kesteren", @"51.934119", @"5.572030400000017" ],
            @[ @"Kerkrade Centrum", @"50.8638504", @"6.0605600000000095" ],
            @[ @"Kapelle-Biezelinge", @"51.4752906", @"3.961281299999996" ],
            @[ @"Kampen Zuid", @"29.554183", @"34.967918000000054" ],
            @[ @"Kampen", @"52.5579645", @"5.914461699999947" ],
            @[ @"IJlst", @"53.00903", @"5.620298000000048" ],
            @[ @"Hurdegaryp", @"53.21487", @"5.941003000000023" ],
            @[ @"Houten Castellum", @"52.0172389", @"5.179281199999991" ],
            @[ @"Houten", @"52.0278426", @"5.16300190000004" ],
            @[ @"Horst-Sevenum", @"51.41063399999999", @"6.0262189000000035" ],
            @[ @"Hoorn Kersenboogerd", @"52.6525831", @"5.086702800000012" ],
            @[ @"Hoorn", @"52.645505", @"5.057526000000053" ],
            @[ @"Hoogkarspel", @"52.69400940000001", @"5.178042000000005" ],
            @[ @"Hoogezand-Sappemeer", @"53.15386299999999", @"6.757725599999958" ],
            @[ @"Hoogeveen", @"52.72571", @"6.479532999999947" ],
            @[ @"Hoofddorp", @"52.3060853", @"4.690704099999948" ],
            @[ @"Holten", @"52.2813889", @"6.418611100000021" ],
            @[ @"Hollandsche Rading", @"52.17697099999999", @"5.177143000000001" ],
            @[ @"Hoensbroek", @"50.918684", @"5.92674999999997" ],
            @[ @"Hoek van Holland Strand", @"51.9816666", @"4.119722400000001" ],
            @[ @"Hoek van Holland Haven", @"51.9752769", @"4.128889100000038" ],
            @[ @"Hindeloopen", @"52.9426846", @"5.401254200000039" ],
            @[ @"Hilversum Sportpark", @"52.2161102", @"5.18722200000002" ],
            @[ @"Hilversum Noord", @"52.2380562", @"5.17388870000002" ],
            @[ @"Hilversum", @"52.2291696", @"5.166897400000039" ],
            @[ @"Hillegom", @"52.293874", @"4.580799999999954" ],
            @[ @"Hengelo Oost", @"52.2688904", @"6.819444699999963" ],
            @[ @"Hengelo Gezondheidspark", @"52.2574121", @"6.7927724999999555" ],
            @[ @"Hengelo FBK stadion", @"52.2574121", @"6.7927724999999555" ],
            @[ @"Hengelo", @"52.2574121", @"6.7927724999999555" ],
            @[ @"Hemmen-Dodewaard", @"51.9222129", @"5.673725399999967" ],
            @[ @"Helmond Brouwhuis", @"51.4598904", @"5.705949099999998" ],
            @[ @"Helmond Brandevoort", @"51.45563509999999", @"5.620231500000045" ],
            @[ @"Helmond 't Hout", @"51.4639037", @"5.638604299999997" ],
            @[ @"Helmond", @"51.4792547", @"5.657009600000038" ],
            @[ @"Heino", @"52.4338808", @"6.232887900000037" ],
            @[ @"Heiloo", @"52.601735", @"4.709876000000008" ],
            @[ @"Heeze", @"51.3809718", @"5.575826300000017" ],
            @[ @"Heerlen Woonboulevard", @"50.88817419999999", @"5.979498799999988" ],
            @[ @"Heerlen De Kissel", @"50.889983", @"5.999839299999962" ],
            @[ @"Heerlen", @"50.88817419999999", @"5.979498799999988" ],
            @[ @"Heerhugowaard", @"52.665051", @"4.830087999999932" ],
            @[ @"Heerenveen IJsstadion", @"52.9402737", @"5.942320300000006" ],
            @[ @"Heerenveen", @"52.9605613", @"5.920521699999995" ],
            @[ @"Heemstede-Aerdenhout", @"52.3591652", @"4.6066666" ],
            @[ @"Heemskerk", @"52.512383", @"4.674996999999962" ],
            @[ @"Harlingen Haven", @"53.1805087", @"5.414073400000007" ],
            @[ @"Harlingen", @"26.1906306", @"-97.69610260000002" ],
            @[ @"Haren", @"52.7941709", @"7.236836600000061" ],
            @[ @"Hardinxveld-Giessendam", @"51.82531299999999", @"4.837113000000045" ],
            @[ @"Hardinxveld Blauwe Zoom", @"51.82944", @"4.815560000000005" ],
            @[ @"Harderwijk", @"52.3422025", @"5.636742300000037" ],
            @[ @"Hardenberg", @"52.5754084", @"6.616694700000039" ],
            @[ @"Haarlem Spaarnwoude", @"52.382636", @"4.6721528" ],
            @[ @"Haarlem", @"52.3880336", @"4.6385848" ],
            @[ @"Grou-Jirnsum", @"53.0888901", @"5.822500200000036" ],
            @[ @"Groningen Noord", @"53.23014689999999", @"6.556317199999967" ],
            @[ @"Groningen Europapark", @"53.2060326", @"6.582827599999973" ],
            @[ @"Groningen", @"53.2193835", @"6.566501799999969" ],
            @[ @"Grijpskerk", @"53.2641667", @"6.306111099999953" ],
            @[ @"Gramsbergen", @"52.6112646", @"6.674114000000031" ],
            @[ @"Gouda Goverwelle", @"52.0068413", @"4.745926199999985" ],
            @[ @"Gouda", @"52.0138589", @"4.709789999999998" ],
            @[ @"Gorinchem", @"51.8372247", @"4.975829200000021" ],
            @[ @"Goor", @"52.2370207", @"6.587249199999974" ],
            @[ @"Goes", @"51.5046455", @"3.8911304000000655" ],
            @[ @"Glanerbrug", @"52.21288759999999", @"6.967255900000055" ],
            @[ @"Gilze-Rijen", @"51.5442814", @"4.941387200000008" ],
            @[ @"Geleen-Lutterade", @"50.9741192", @"5.827989300000013" ],
            @[ @"Geleen Oost", @"50.9669456", @"5.843055700000036" ],
            @[ @"Geldrop", @"51.424467", @"5.561608999999976" ],
            @[ @"Geldermalsen", @"51.8788889", @"5.289722200000028" ],
            @[ @"Geerdijk", @"52.4767248", @"6.571054000000004" ],
            @[ @"Gaanderen", @"51.9302044", @"6.347753099999977" ],
            @[ @"Franeker", @"53.18845899999999", @"5.540455999999949" ],
            @[ @"Eygelshoven Markt", @"50.89418", @"6.059750000000008" ],
            @[ @"Eygelshoven", @"50.8942089", @"6.059043999999972" ],
            @[ @"Etten-Leur", @"51.5781545", @"4.6493875999999545" ],
            @[ @"Ermelo", @"52.2986655", @"5.629619400000024" ],
            @[ @"Enschede Drienerlo", @"52.23749919999999", @"6.83888909999996" ],
            @[ @"Enschede De Eschmarke", @"52.21763319999999", @"6.960508200000049" ],
            @[ @"Enschede", @"52.2215372", @"6.893661899999984" ],
            @[ @"Enkhuizen", @"52.7153849", @"5.284683099999938" ],
            @[ @"Emmen Zuid", @"52.7488664", @"6.874780699999974" ],
            @[ @"Emmen", @"52.7858037", @"6.897585100000015" ],
            @[ @"Elst", @"51.9192887", @"5.84736190000001" ],
            @[ @"Eindhoven Stadion", @"51.4123001", @"5.480156999999963" ],
            @[ @"Eindhoven Beukenlaan", @"51.444413", @"5.4489141000000245" ],
            @[ @"Eindhoven", @"51.44164199999999", @"5.469722499999989" ],
            @[ @"Ede-Wageningen", @"51.9691868", @"5.665394800000058" ],
            @[ @"Ede Centrum", @"52.12716", @"5.755869999999959" ],
            @[ @"Echt", @"51.1034765", @"5.874584000000027" ],
            @[ @"Duivendrecht", @"52.331389", @"4.939166999999998" ],
            @[ @"Duiven", @"51.9474576", @"6.017949600000065" ],
            @[ @"Dronrijp", @"53.19508099999999", @"5.644130000000018" ],
            @[ @"Driehuis", @"52.4472222", @"4.636666699999978" ],
            @[ @"Driebergen-Zeist", @"52.056598", @"5.2905490000000555" ],
            @[ @"Dordrecht Zuid", @"51.7900009", @"4.671389099999942" ],
            @[ @"Dordrecht Stadspolders", @"51.8025993", @"4.721127499999966" ],
            @[ @"Dordrecht", @"51.797387", @"4.673478899999964" ],
            @[ @"Doetinchem De Huet", @"51.9634844", @"6.259540099999981" ],
            @[ @"Doetinchem", @"51.96469949999999", @"6.293773600000009" ],
            @[ @"Dieren", @"52.0527254", @"6.09558190000007" ],
            @[ @"Diemen Zuid", @"52.3302765", @"4.95583339999996" ],
            @[ @"Diemen", @"52.3389926", @"4.959188799999993" ],
            @[ @"Didam", @"51.940262", @"6.1320799999999736" ],
            @[ @"Deventer De Scheg", @"52.2491232", @"6.213679400000046" ],
            @[ @"Deventer Colmschate", @"52.2486908", @"6.221663000000035" ],
            @[ @"Deventer", @"52.26007999999999", @"6.16483889999995" ],
            @[ @"Deurne", @"51.4642201", @"5.795067900000049" ],
            @[ @"Den Helder Zuid", @"52.9324989", @"4.764166799999998" ],
            @[ @"Den Helder", @"52.95628079999999", @"4.76079720000007" ],
            @[ @"Den Haag Ypenburg", @"52.03977709999999", @"4.365631000000008" ],
            @[ @"Den Haag Moerwijk", @"52.0478362", @"4.2892888000000085" ],
            @[ @"Den Haag Mariahoeve", @"52.0936444", @"4.359234399999991" ],
            @[ @"Den Haag Centraal", @"52.0816886", @"4.325771300000042" ],
            @[ @"Den Dolder", @"52.1390592", @"5.242827900000066" ],
            @[ @"Delfzijl West", @"53.331643", @"6.9069979999999305" ],
            @[ @"Delfzijl", @"53.331643", @"6.9069979999999305" ],
            @[ @"Delft Zuid", @"51.9908333", @"4.3647223" ],
            @[ @"Delft", @"52.0066681", @"4.356389" ],
            @[ @"Delden", @"52.25999789999999", @"6.709210900000016" ],
            @[ @"Deinum", @"53.1918429", @"5.724977800000033" ],
            @[ @"De Vink", @"52.1472206", @"4.456388999999945" ],
            @[ @"Dalfsen", @"52.507755", @"6.259667000000036" ],
            @[ @"Daarlerveen", @"52.4427788", @"6.577088099999969" ],
            @[ @"Culemborg", @"51.9561076", @"5.240044799999964" ],
            @[ @"Cuijk", @"51.728281", @"5.877144899999962" ],
            @[ @"Coevorden", @"52.6613567", @"6.741061599999966" ],
            @[ @"Chevremont", @"47.628817", @"6.921039999999948" ],
            @[ @"Bussum Zuid", @"52.2724092", @"5.175292500000069" ],
            @[ @"Bunnik", @"52.0672222", @"5.196944400000007" ],
            @[ @"Bunde", @"52.1982222", @"8.58323329999996" ],
            @[ @"Buitenpost", @"53.25", @"6.149999999999977" ],
            @[ @"Brummen", @"52.093262", @"6.157771000000025" ],
            @[ @"Breukelen", @"52.1710222", @"5.0013289999999415" ],
            @[ @"Breda-Prinsenbeek", @"51.6161733", @"4.6928044" ],
            @[ @"Breda", @"51.58307", @"4.776950499999998" ],
            @[ @"Boxtel", @"51.589498", @"5.327070999999933" ],
            @[ @"Boxmeer", @"51.647867", @"5.947047999999995" ],
            @[ @"Bovenkarspel-Grootebroek", @"52.6949997", @"5.237777700000038" ],
            @[ @"Bovenkarspel Flora", @"52.6961098", @"5.252777599999945" ],
            @[ @"Boskoop", @"52.0742845", @"4.6584761999999955" ],
            @[ @"Borne", @"52.3002366", @"6.753725799999984" ],
            @[ @"Bodegraven", @"52.085793", @"4.74975500000005" ],
            @[ @"Bloemendaal", @"52.4043117", @"4.6273518" ],
            @[ @"Blerick", @"51.3690094", @"6.148376999999982" ],
            @[ @"Bilthoven", @"52.1365344", @"5.210380600000008" ],
            @[ @"Beverwijk", @"52.4853691", @"4.6688894999999775" ],
            @[ @"Best", @"51.513533", @"5.395898999999986" ],
            @[ @"Bergen op Zoom", @"51.49457580000001", @"4.287162200000012" ],
            @[ @"Beilen", @"52.8566667", @"6.511111099999994" ],
            @[ @"Beesd", @"51.8874751", @"5.194001599999979" ],
            @[ @"Beek-Elsloo", @"50.95027779999999", @"5.768611100000044" ],
            @[ @"Bedum", @"53.3016754", @"6.599828800000068" ],
            @[ @"Barneveld Noord", @"52.1578537", @"5.464201000000003" ],
            @[ @"Barneveld Centrum", @"52.18622999999999", @"5.692340000000058" ],
            @[ @"Barendrecht", @"51.8546539", @"4.535237999999936" ],
            @[ @"Baflo", @"53.3626014", @"6.514347000000043" ],
            @[ @"Baarn", @"52.21318249999999", @"5.28640960000007" ],
            @[ @"Assen", @"52.992753", @"6.564228400000047" ],
            @[ @"Arnhem Zuid", @"51.9550018", @"5.851944399999979" ],
            @[ @"Arnhem Velperpoort", @"51.9852791", @"5.91944460000002" ],
            @[ @"Arnhem Presikhaaf", @"51.9861608", @"5.94868919999999" ],
            @[ @"Arnhem", @"51.9851034", @"5.898729600000024" ],
            @[ @"Arnemuiden", @"51.5011231", @"3.675901500000009" ],
            @[ @"Arkel", @"51.86573929999999", @"4.997499299999959" ],
            @[ @"Appingedam", @"53.3206783", @"6.854421799999955" ],
            @[ @"Apeldoorn Osseveld", @"52.2136766", @"5.992627299999981" ],
            @[ @"Apeldoorn De Maten", @"52.1866031", @"6.008771199999956" ],
            @[ @"Apeldoorn", @"52.21115700000001", @"5.96992309999996" ],
            @[ @"Anna Paulowna", @"52.8616158", @"4.823809100000062" ],
            @[ @"Amsterdam Zuid", @"52.3463889", @"4.858611099999962" ],
            @[ @"Amsterdam Sloterdijk", @"52.3889445", @"4.8375603" ],
            @[ @"Amsterdam Science Park", @"52.3544521", @"4.9541977999999744" ],
            @[ @"Amsterdam RAI", @"52.3372231", @"4.890277900000001" ],
            @[ @"Amsterdam Muiderpoort", @"52.3636372", @"4.919502100000045" ],
            @[ @"Amsterdam Lelylaan", @"52.3577766", @"4.833888999999999" ],
            @[ @"Amsterdam Holendrecht", @"52.2995922", @"4.96557949999999" ],
            @[ @"Amsterdam Centraal", @"52.3788872", @"4.9002776" ],
            @[ @"Amsterdam Bijlmer ArenA", @"52.3122215", @"4.946944199999962" ],
            @[ @"Amsterdam Arena", @"20.5404381", @"-100.39461900000003" ],
            @[ @"Amsterdam Amstel", @"52.2870776", @"4.82644920000007" ],
            @[ @"Amersfoort Vathorst", @"52.19739999999999", @"5.412311100000011" ],
            @[ @"Amersfoort Schothorst", @"52.1719891", @"5.390115100000003" ],
            @[ @"Amersfoort", @"52.1561113", @"5.387826600000039" ],
            @[ @"Alphen aan den Rijn", @"52.1276577", @"4.668850799999973" ],
            @[ @"Almere Parkwijk", @"52.3715889", @"5.246935200000053" ],
            @[ @"Almere Oostvaarders", @"52.4033318", @"5.300555700000018" ],
            @[ @"Almere Muziekwijk", @"52.3707905", @"5.187378699999954" ],
            @[ @"Almere Centrum", @"52.37503", @"5.21763999999996" ],
            @[ @"Almere Buiten", @"52.4081006", @"5.262477799999942" ],
            @[ @"Almelo de Riet", @"52.34184510000001", @"6.669515600000068" ],
            @[ @"Almelo", @"52.355759", @"6.663057999999978" ],
            @[ @"Alkmaar Noord", @"52.6590406", @"4.757561099999975" ],
            @[ @"Alkmaar", @"52.632281", @"4.750806000000011" ],
            @[ @"Akkrum", @"53.05", @"5.833333000000039" ],
            @[ @"Abcoude", @"52.272071", @"4.970474299999978" ],
            @[ @"Aalten", @"51.9266666", @"6.580678499999976" ],
            @[ @"'t Harde", @"52.4152778", @"5.880833299999949" ],
            @[ @"'s-Hertogenbosch Oost", @"51.7005539", @"5.318333100000018" ],
            @[ @"'s-Hertogenbosch", @"51.697928", @"5.317005999999992" ]
        ]];
    }
    
    return sharedInstance;
}

#pragma mark - Setters

- (void)setFrom:(NSString *)from
{
    _from = from;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_from forKey:@"from"];
}

- (void)setTo:(NSString *)to
{
    _to = to;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_to forKey:@"to"];
}

#pragma mark - NSURLRequests

- (NSURLRequest *)requestWithFrom:(NSString *)from to:(NSString *)to
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ns.nl/reisplanner-v2/index.shtml"]];
    [request setHTTPMethod:@"POST"];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSString *postString = [NSString stringWithFormat:@"show-reisplannertips=true&language=en&js-action=%%2Freisplanner-v2%%2Findex.shtml&SITESTAT_ELEMENTS=sitestatElementsReisplannerV2&POST_AUTOCOMPLETE=%%2Freisplanner-v2%%2Fautocomplete.ajax&POST_VALIDATE=%%2Freisplanner-v2%%2FtravelAdviceValidation.ajax&outwardTrip.fromLocation.locationType=STATION&outwardTrip.fromLocation.name=%@&outwardTrip.toLocation.locationType=STATION&outwardTrip.toLocation.name=%@&outwardTrip.viaStationName=&outwardTrip.dateType=specified&outwardTrip.day=%i&outwardTrip.month=%i&outwardTrip.year=%i&outwardTrip.hour=%i&outwardTrip.minute=%i&outwardTrip.arrivalTime=false&submit-search=Give+trip+and+price", from, to, day, month, year, hour, minute];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSURLRequest *)requestForMoreWithFrom:(NSString *)from to:(NSString *)to
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ns.nl/reisplanner-v2/earlierLater.ajax"]];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = @"direction=outwardTrip&type=later";
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

#pragma mark - Fetching

- (void)fetchWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure
{
    NSURLRequest *urlRequest = [self requestWithFrom:self.from to:self.to];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *document = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [document searchWithXPathQuery:@"//table[@class='time-table']/tbody/tr"];
        
        success([self trainsWithHTMLElements:elements]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
}

- (void)fetchMoreWithSuccess:(void (^)(NSArray *trains))success failure:(void (^)(NSError *error))failure
{
    NSURLRequest *urlRequest = [self requestForMoreWithFrom:self.from to:self.to];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success([self trainsWithXMLData:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
}

#pragma mark - Element searching

- (NSArray *)trainsWithHTMLElements:(NSArray *)elements {
    NSMutableArray *trains = [NSMutableArray array];
    BOOL foundSelected = NO;
    
    for (TFHppleElement *element in elements) {
        Train *train = [[Train alloc] init];
        
        // Check if something has been selected
        if (!foundSelected) {
            if ([[element objectForKey:@"class"] isEqualToString:@"selected"]) {
                foundSelected = YES;
            } else {
                continue;
            }
        }
        
        // Simple fields
        [train setPlatform:[self normalizeString:[[element firstChildWithClassName:@"platform"] text]]];
        [train setTravelTime:[[[self normalizeString:[[element firstChildWithClassName:@"travel-time"] text]] stringByReplacingOccurrencesOfString:@"0:" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@"h "]];
        
        // Dates
        NSString *departureString = [NSString stringWithFormat:@"%@ %@", [self normalizeString:[[element firstChildWithClassName:@"departure-date"] text]], [self normalizeString:[[element firstChildWithClassName:@"departure"] text]]];
        NSString *arrivalString = [NSString stringWithFormat:@"%@ %@", [self normalizeString:[[element firstChildWithClassName:@"arrival-date"] text]], [self normalizeString:[[element firstChildWithClassName:@"arrival"] text]]];
        
        NSDate *departure = [self dateForString:departureString];
        [train setDeparture:departure];
        [train setArrival:[self dateForString:arrivalString]];
        
        NSInteger diff = ([departure timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate]) / 60;
        if (diff > 60) {
            continue;
        }
        
        // Delays
        NSArray *departureDelay = [[element firstChildWithClassName:@"departure"] childrenWithTagName:@"strong"];
        if (departureDelay && [departureDelay count] > 0) {
            [train setDepartureDelay:[self normalizeString:[[departureDelay objectAtIndex:0] text]]];
        }
        
        NSArray *arrivalDelay = [[element firstChildWithClassName:@"arrival"] childrenWithTagName:@"strong"];
        if (arrivalDelay && [arrivalDelay count] > 0) {
            [train setArrivalDelay:[self normalizeString:[[arrivalDelay objectAtIndex:0] text]]];
        }
        
        // Error Logging
        if (![train departure]) {
            NSLog(@"NSRailConnection: train has no departure.\n\n%@", element);
            continue;
        }
        
        [trains addObject:train];
    }
    
    return trains;
}

- (NSArray *)trainsWithXMLData:(NSData *)data {
    NSMutableArray *trains = [NSMutableArray array];
    
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    NSArray *elements = [document nodesForXPath:@"//reistijden/reizen/reis" error:nil];
    
    for (DDXMLElement *element in elements) {
        Train *train = [[Train alloc] init];
    
        // Simple fields
        [train setPlatform:[self normalizeString:[[[element nodesForXPath:@"aankomstspoor" error:nil] objectAtIndex:0] stringValue]]];
        [train setTravelTime:[[[self normalizeString:[[[element nodesForXPath:@"reistijd" error:nil] objectAtIndex:0] stringValue]] stringByReplacingOccurrencesOfString:@"0:" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@"h "]];
        
        // Delays
        NSString *departureDeley = @"";
        NSString *departureTimeString = [self normalizeString:[[[element nodesForXPath:@"vertrek" error:nil] objectAtIndex:0] stringValue]];
        TFHpple *departureElements = [[TFHpple alloc] initWithHTMLData:[departureTimeString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSArray *departureArray = [departureElements searchWithXPathQuery:@"//text()"];
        
        if ([departureArray count] > 0) {
            departureTimeString = [self normalizeString:[[departureArray objectAtIndex:0] content]];
        }
        
        if ([departureArray count] > 1) {
            departureDeley = [self normalizeString:[[departureArray objectAtIndex:1] content]];
        }
        
        if (departureDeley && ![departureDeley isEqualToString:@""]) {
            [train setDepartureDelay:departureDeley];
        }
        
        NSString *departureString = [NSString stringWithFormat:@"%@ %@", [self normalizeString:[[[element nodesForXPath:@"vertrekdatum" error:nil] objectAtIndex:0] stringValue]], departureTimeString];
        NSString *arrivalString = [NSString stringWithFormat:@"%@ %@", [self normalizeString:[[[element nodesForXPath:@"aankomstdatum" error:nil] objectAtIndex:0] stringValue]], [self normalizeString:[[[element nodesForXPath:@"aankomst" error:nil] objectAtIndex:0] stringValue]]];

        NSDate *departure = [self dateForString:departureString];
        [train setDeparture:departure];
        [train setArrival:[self dateForString:arrivalString]];
        
        // Error Logging
        if (![train departure]) {
            NSLog(@"NSRailConnection: train has no departure.\n\n%@", element);
            continue;
        }
        
        NSInteger diff = ([departure timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate]) / 60;
        if (diff > 59) {
            continue;
        }
        
        [trains addObject:train];
    }
    
    return trains;
}

#pragma mark - Stations

- (void)setStations:(NSArray *)stations
{
    // update all locations to CLLocations
    NSMutableArray *newStations = [NSMutableArray array];
    
    [stations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *station = (NSArray *)obj;
        
        // get the location of the station
        CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:[[station objectAtIndex:1] doubleValue] longitude:[[station objectAtIndex:2] doubleValue]];
        
        [newStations addObject:@[
            [station objectAtIndex:0],
            stationLocation
        ]];
    }];
    
    _stations = newStations;
}

#pragma mark - Helpers

- (NSDate *)dateForString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDate *sourceDate = [dateFormatter dateFromString:string];
    
    return sourceDate;
}

- (NSString *)normalizeString:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
