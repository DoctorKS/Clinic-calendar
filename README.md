# 🏥 จัดการเวรคลินิก · Clinic Duty Tracker

เครื่องมือส่วนตัวสำหรับบันทึกและสรุปรายได้จากการทำเวรคลินิก  
A personal web app for tracking clinic duty shifts and income.

---

## ✨ Features · ฟีเจอร์หลัก

### 📅 ปฏิทินรายเดือน · Monthly Calendar
- บันทึกข้อมูลแต่ละวันที่ทำเวร
- แสดงยอดรายได้บนตารางปฏิทิน
- Badge สีประจำคลินิกบนแต่ละวัน
- ค่าแขวนป้ายคลินิกรายเดือน (แยกแต่ละเดือน)

### 🏷 จัดการคลินิก · Clinic Management
- เพิ่ม / แก้ไข / ลบ คลินิกได้ไม่จำกัด
- ตั้งค่า Default: ค่านั่ง, จำนวนชั่วโมง, % DF หัตถการ, % DF เครื่อง
- เงื่อนไขพิเศษ **การันตี** — เอาแบบที่มากกว่าระหว่าง (ชม.+DF) กับ เวรเหมา

### 👤 บันทึกรายวัน · Daily Entry
- คนไข้คนที่ 1, 2, 3... — แต่ละคนมีหัตถการหลายรายการ
- หัตถการแต่ละรายการ: ชื่อหัตถการ (dropdown), ชื่อทางการค้า (autocomplete), ปริมาณ
- **DF พิเศษ** ต่อหัตถการ — เลือกได้ระหว่าง % หรือ Fixed cost (บาท)
- ราคาคอร์สรวมต่อคนไข้ 1 คน
- บันทึกเครื่อง: ชื่อเครื่อง, ราคา, ปริมาณ/ช็อต
- เวรเหมา (เพิ่มเติมได้)

### 📊 สรุปรายงาน · Reports
| รายงาน | รายละเอียด |
|--------|-----------|
| 💰 สรุปค่าเวร | แยกตามคลินิก: ค่านั่ง, DF หัตถการ, DF เครื่อง, DF รวม, เวรเหมา |
| 📋 สรุปหัตถการ | จำนวนครั้งและปริมาณรวม แยกตามชื่อหัตถการ / ชื่อทางการค้า |
| 📸 บันทึกรูป | Export รายงานเป็น PNG |

### 💾 Backup & Restore
- Export ข้อมูลทั้งหมดเป็น `.json`
- Import กลับได้ทุกเมื่อ
- รองรับ **Supabase** สำหรับ cloud sync ข้าม device

---

## 🚀 วิธีใช้งาน · How to Use

### เปิดใช้งาน
เข้าผ่าน browser โดยตรง — ไม่ต้องติดตั้ง

```
https://doctorks.github.io/Clinic-calendar/
```

### เพิ่มลง Home Screen (iPhone)
1. เปิด URL ใน **Safari**
2. กดปุ่ม Share → **Add to Home Screen**
3. ชื่อ: **จัดการเวรคลินิก**

---

## ☁️ Cloud Sync (Supabase) — Required for multi-device

แอปใช้ **Local-First architecture** — ทุกการบันทึกเก็บใน localStorage ทันที
และ sync ไป Supabase เป็น background queue ในภายหลัง:
- ทำงานได้แม้ offline / Wi-Fi ขาดหาย — ข้อมูลค้างใน queue และ sync เมื่อเชื่อมต่อได้
- ต้อง login Supabase อย่างน้อยครั้งแรกเพื่อตั้ง user identity (ใช้เป็น key prefix)
- ข้าม device ผ่าน Supabase: บันทึกที่ iPhone → sync ขึ้น cloud → เปิดที่ Mac → ดึงลงมา

ตั้งค่า Supabase:

1. สมัคร [supabase.com](https://supabase.com) (ฟรี)
2. สร้าง project → รัน SQL schema จากไฟล์ `supabase_schema.sql`
3. แก้ไขใน `index.html`:
```javascript
const SB_URL = 'https://xxxxxxxxxxxx.supabase.co';
const SB_KEY = 'your-anon-public-key';
```
4. กดปุ่ม 🔑 **Login** ในแอป → เข้าสู่ระบบ → ข้อมูล sync อัตโนมัติทั้งสองทาง

---

## 🗂 โครงสร้างไฟล์ · File Structure

```
Clinic-calendar/
├── index.html              # แอปหลัก (single-file HTML)
├── supabase_schema.sql     # SQL schema สำหรับ Supabase
├── CLAUDE.md               # Project doc + Claude guardrails
└── README.md
```

---

## 🔒 ความเป็นส่วนตัว · Privacy

- ข้อมูลเก็บใน 2 ที่: **localStorage บนเครื่อง** (cache + sync queue ของ
  user คุณเอง ภายใต้ prefix `app_<userId>_*`) และ **Supabase project ของ
  คุณเอง** (account ฟรี — cross-device truth)
- Multi-account บนเครื่องเดียวกัน: แยกข้อมูลผ่าน user-id prefix อัตโนมัติ
- ไม่มี analytics, ไม่ส่งข้อมูลให้บุคคลที่สามนอกจาก Supabase ที่คุณตั้งเอง

---

## 📱 Compatibility

| Platform | Browser | รองรับ |
|----------|---------|--------|
| iPhone / iPad | Safari | ✅ |
| Mac | Chrome / Safari | ✅ |
| Android | Chrome | ✅ |

---

## ⚠️ หมายเหตุสำคัญ · Important Notes

**Login Supabase อย่างน้อยครั้งแรก** เพื่อตั้ง user identity บนเครื่อง
หลังจากนั้นใช้งาน offline ได้ — บันทึกเก็บในเครื่องและ queue จะ sync
เมื่อเชื่อมต่อได้

- ✅ **บันทึกได้แม้ offline** — UI ปิดทันที queue catches up เมื่อ online
- 🔄 แถบสี amber `"sync ค้าง N รายการ"` = ข้อมูลในเครื่อง รอ sync เมื่อเชื่อมต่อ
- ❌ แถบสีแดง `"ค้าง sync N รายการ — แตะ ⬆ เพื่อลองใหม่"` = หลัง retry 5 ครั้ง
  ยังล้ม กดปุ่ม ⬆ เพื่อลอง resync แบบ manual
- ปุ่ม ⬆ = force-resync ข้อมูลในเครื่อง + retry dead-letter entries
- ปุ่ม ↻ = โหลดแอปเวอร์ชันล่าสุดจาก server (cache + sync queue ไม่หาย,
  ไม่ดึงข้อมูลใหม่จาก Supabase — ใช้ปุ่ม ⬆ ถ้าต้องการ resync ขึ้น cloud,
  หรือ logout/login ถ้าต้องการ pull ลงมาใหม่)

**iOS Safari ITP** — Safari อาจ wipe localStorage หลังไม่ได้เปิดแอป ~7 วัน
ข้อมูลใน Supabase ยังอยู่ครบ; เปิดแอปแล้ว pull ลงมาใหม่อัตโนมัติ

**แนะนำ:** Export JSON สำรองไว้บางครั้ง เผื่อ Supabase project หาย

---

*Personal project · ใช้งานส่วนตัว*
