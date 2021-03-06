﻿local null = nil
local var = 
{
	[ [=[1]=] ]=
	{
		[ [=[desc]=] ]=[=[ห้องโถงนักเตะคือวิธีเล่นประเภทสะสมนักเตะ ภายในโถงจะมีห้องโถงเล็กๆ ในธีมที่แตกต่างกัน ห้องโถงนักเตะแต่ละห้องจะสร้างขึ้นโดยผู้เล่นหลายคน ขณะเดียวกันแต่ละห้องยังมีเงื่อนไขการปลดล็อคที่สอดคล้องกันอีกด้วย เมื่อบรรลุเงื่อนไขก็จะสามารถปลดล็อคห้องโถงที่กำหนดได้ 
ในโถงจะเพิ่มคุณสมบัติและเลเวลทักษะทั้งหมดแก่นักเตะให้สอดคล้องตามเงื่อนไขที่อยู่ในเกมทั้งหมด (เช่นผู้เล่นสเปนทั้งหมดเป็นต้น) ผู้เล่นสามารถเพิ่มความแข็งแกร่งให้กับคุณสมบุติโดยรวมของนักเตะพิเศษเหล่านี้ได้ด้วยการอัพเกรดเลเวลตราของโถงนักเตะหรือด้วยการพัฒนานักเตะ 
คุณสมับติร้อยละที่นักเตะพิเศษมมีประกอบจากสองด้านด้วยกัน: 
คุณสมับติพื้นฐาน: เลเวลคุณสมบัติพื้นฐานและตราห้องโถงยิ่งสูง คุณสมบัติพื้นฐานที่ตราห้องโถงนักเตะมีให้ก็จะยิ่งมาก 
คุณสมบัติเพิ่มเติม: คุณสมบัติเพิ่มเติมจะสอดคล้องกับสภาพการบ่มเพาะนักเตะคนนั้น ทั้งคุณภาพผู้เล่น การเลื่อนขั้น เกิดใหม่ ฝึกพิเศษล้วนจะช่วยโบนัสเปอร์เซ็นต์ให้คุณสมับติพื้นฐาน 
คุณภาพตราโถงนักเตะมีทั้งหมด 8 ระดับ แบ่งออกเป็น เบรส บรอนซ์  ซิลเวอร์ โกลด์ แบล็คโกลด์ แพลตินัม เรดโกลด์ บลูโกลด์ เว้นแต่เบรสที่มีแค่ระดับความเสียหาย นอกนั้นคุณภาพแต่ละอย่างมีด้วยกัน 4 เลเวล แบ่งออกเป็น ระดับฝึกหัด ระดับธรรมดา ระดับปรมาจารย์ ระดับช่าง แต่ละระดับชั้นล้วนช่วยให้โบนัสคุณสมับติพื้นฐานเพิ่มขึ้นทั้งสิ้น 
รายละเอียดโบนัสมีดังนี้: 
ระดับความเสียหาย: โบนัสคุณสมบัติ 4 
โบนัสคุณสมบัติระดับบรอนซ์: 19/27/34/44 (โบนัสตามแต่ละเลเวล) 
โบนัสคุณสมบัติระดับซิลเวอร์: 53/63/72/84
โบนัสคุณสมบัติระดับโกลด์: 95/107/118/131 และเลเวลทักษะทั้งหมดผู้เล่นคุณภาพ D/C/B/A จะ +1
โบนัสคุณสมับติระดับแบล็คโกลด์: 145/158/171/187  และเลเวลทักษะผู้เล่นคุณภาพ D/C/B/A/S จะ +1
โบนัสคุณสมับติระดับแพลตินัม: 202/217/232/250 และเลเวลทักษะผู้เล่นคุณภาพ D/C/B/A/S/SS/SS+ จะ +1
โบนัสคุณสมับติระดับเรดโกลด์: 267/284/301/320 และเลเวลการ์ดทักษะทั้งหมดจะ +1
โบนัสคุณสมับติระดับบลูโกลด์: 339/358/377/400 และเลเวลทักษะเพิ่มเติมของนักเตะทุกคุณภาพจะ +2
นักเตะแต่ละคนจะมีตำแหน่งที่เหมาะสมที่สุดเพื่อใช้ในการตัดสินโบนัส โถงนักเตะจะเพิ่มโบนัสให้แต่นักเตะที่อยู่ในตำแหน่งที่เหมาะสมที่สุด เช่น: นักเตะ A สามารถเล่นในตำแหน่ง FC/FL/FR แต่ตำแหน่งที่เหมาะที่สุดคือกองหน้า จึงได้รับโบนัสห้องโถงที่เกี่ยวกับ FC เท่านั้น]=],
		[ [=[title]=] ]=[=[บทนำ]=]
	}
}
return var