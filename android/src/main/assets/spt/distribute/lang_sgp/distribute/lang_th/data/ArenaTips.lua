﻿local null = nil
local var = 
{
	[ [=[1]=] ]=
	{
		[ [=[position]=] ]=[=[รายละเอียดเกม]=],
		[ [=[desc]=] ]=[=[1.การแข่ขันแชมเปียนส์ลีกใช้ระบบการแข่งขันของยูฟ่าแชมเปียนส์ลีก โดยแบ่งผู้เล่นทุกๆ 32 คนที่มีความสามารถใกล้เคียงกันเป็นหนึ่งกลุ่ม และทำการแข่งขันรอบคัดเลือกกับรอบแพ้คัดออกเพื่อทำการหาแชมป์ในสุดท้าย ระนะเวลาฤดูกาลของการแข่งขันคือ 7 วัน หลังจากจบการแข่งขันของผู้เล่นเองก็สามารถเริ่มการแข่งขันฤดูกาลใหม่ได้ 
2.หลังจากจบเกม ผู้เล่นจะได้รับเหรียญรางวัลและคะแนนสะสมที่บวกลบตามอันดับของการจัดอันดับ และคะแนนสะสมจะเป็นตัวตัดสินตำแหน่งขั้นของผู้เล่น เหรียญรางวัลที่ได้รับสามารถแลกของรางวัล้ที่ร้านค้าได้：ในเขตการต่อสู้ที่แตกต่างกันจะได้รับเหรียญรางวัลที่ไม่เหมือนกัน ซึ่ง 3 เขตการต่อสู้ในนั้นได้แก่ เขตทองคำแดง เขตครบรอบปีและเขตขั้นสุดยอดจะได้รับเหรียญรางวัล 1 ชนิด ตำแหน่งขั้นยิ่งสูงจะได้รับของรางวัลยิ่งมาก 
3.การแข่งขันยูฟ่าแชมเปียนส์ลีก้แบ่งออกเป็น 7 เขต เขตเงิน：แจะอนุญาติให้ใช้แค่นักเตะคุณภาพที่ต่ำกว่า B ลงไป เขตทอง：จะอนุญาติให้ใช้แค่นักเตะคุณภาพที่ต่ำกว่า A ลงไป เขตทองดำ：จะอนุญาติให้ใช้แค่นักเตะคุณภาพที่ต่ำกว่า S ลงไป เขตแพลทินัม：จะอนุญาติให้ใช้นักเตะคุณภาพใดก็ได้ เขตทองคำแดง：จะอนุญาติให้ใช้แค่นักเตะคุณภาพ SS+ เขตครบรอบปี：จะอนุญาติให้ใช้แค่นักเตะครบปีกับนักเตะคอลเลคชั่น เขตขั้นสุดยอด：จะอนุญาติให้ใช้แค่นักเตะ SSS นักเตะตำนานและนักเตะคุณภาพ SL 
4.สมัครเข้าร่วมได้ 2 เขตในเวลาเดียวกัน：สามารถเลือกสมัครหนึ่งในเขตเงิน ทอง ทองดำ และแพลทินัมได้หนึ่งเขต สามารถเลือกสมัครหนึ่งในเขตเงิน ทองคำแดง ครอบรอบปี และขั้นสุดยอดได้หนึ่งอย่าง 
5.ในแต่ละเขตจะมีตำแหน่งขั้นที่เป็นของตัวเอง ตำแหน่งขั้นจากต่ำไปสูงตามลำดับคือ：ทีมน้องใหม่ ทีมมืออาชีพ ทีมยอดฝีมือ ทีมคิง ทีมตำนานและทีมลมและเมฆ 
6.ผู้เล่นสามารถสมัครในเวลาใดก็ได้ที่นอกช่วงเวลาสรุปรอบการแบ่งกลุ่ม จะประกาศผลการแบ่งกลุ่มทุกวันในเวลา 22.00 น. ฤดูกาลของการแข่งขันจะเริ่มอย่างเป็นทางการในวันถัดไป สามารถออกมาได้ก่อนการแบ่งกลุ่มเพื่อสมัครใหม่ 
7.ระบบสภาพอากาศและสนามหญ้าจะมีผลในวิธีเล่นยูฟ่าแชมเปียนส์ลีก （การแข่งขันนัดชิงใช้สนามกลางและสภาพอากาศกับสนามหญ้าจะไม่มีผล）]=],
		[ [=[title]=] ]=[=[รายละเอียดเกม]=]
	},
	[ [=[2]=] ]=
	{
		[ [=[position]=] ]=[=[รอบแบ่งกลุ่ม]=],
		[ [=[desc]=] ]=[=[1. ชนะได้ 3 แต้ม เสมอได้ 1 แต้ม แพ้ 0 แต้ม เมื่อสิ้นสุดรอบแบ่งกลุ่ม อันดับจะได้เรียงตามแต้มสูงถึงต่ำ
2. หากมีสองทีมขึ้นไปที่มีแต้มเท่ากัน จะได้เรียงตามดังนี้:
แต้มในรอบแบ่งกลุ่มที่สูงกว่าระหว่าง 2 ทีม
ประตูได้เสียในรอบแบ่งกลุ่มที่สูงกว่าระหว่าง 2 ทีม
จำนวนประตูได้มาในรอบแบ่งกลุ่มที่สูงกว่าระหว่าง 2 ทีม
จำนวนประตูได้ที่สนามเยือนในรอบแบ่งกลุ่มที่สูงกว่าระหว่าง 2 ทีม
จับฉลากเพื่อตัดสิน]=],
		[ [=[title]=] ]=[=[รายละเอียดรอบแบ่งกลุ่ม]=]
	},
	[ [=[3]=] ]=
	{
		[ [=[position]=] ]=[=[แพ้คัดออก]=],
		[ [=[desc]=] ]=[=[1. รอบ 8 ทีมสุดท้าย และรอบ 4 ทีมสุดท้ายใช้กติกา 2 ครึ้ง เกมเยือน-เกมเหย้า
ทีมที่ทำประตูมากกว่าจะเข้ารอบต่อไป
หากเสมอกัน ทีมทำประตูมากกว่าที่สนามเยือนจะเข้ารอบต่อไป
หากเสมอกัน จะต่อเวลา (ประตูในช่วงต่อเวลา จะนับเป็นประตูทำที่สนามเยือน)
หากต่อเวลาแล้ว แต่เสมอกัน จะดวลจุดโทษ
2. รอบชิงชนะเลิศใช้กติกาแข่งเกมเดียว หลัง 90 นาทีของเกม หากเสมอกัน จะต่อเวลา หากยังเสมอ จะดวลจุดโทษ]=],
		[ [=[title]=] ]=[=[รายละเอียดการแพ้คัดออก]=]
	}
}
return var