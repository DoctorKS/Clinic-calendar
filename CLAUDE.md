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

## ☁️ Cloud Sync (Supabase) — Optional

สำหรับ sync ข้อมูลข้าม device:

1. สมัคร [supabase.com](https://supabase.com) (ฟรี)
2. สร้าง project → รัน SQL schema จากไฟล์ `supabase_schema.sql`
3. แก้ไขใน `clinic_patient.html`:
```javascript
const SB_URL = 'https://xxxxxxxxxxxx.supabase.co';
const SB_KEY = 'your-anon-public-key';
```
4. กดปุ่ม 🔑 **Login** ในแอป → เข้าสู่ระบบ → ข้อมูล sync อัตโนมัติ

---

## 🗂 โครงสร้างไฟล์ · File Structure

```
Clinic-calendar/
├── clinic_patient.html      # แอปหลัก (single-file HTML)
├── supabase_schema.sql      # SQL schema สำหรับ Supabase
├── apple-touch-icon.png     # App icon สำหรับ iPhone home screen
└── README.md
```

---

## 🔒 ความเป็นส่วนตัว · Privacy

- ข้อมูลทั้งหมดเก็บใน **localStorage** บนเครื่องตัวเอง
- ไม่มี server, ไม่มี analytics, ไม่มีการส่งข้อมูลออกภายนอก
- Supabase sync เป็น optional — ข้อมูลอยู่ใน project ของตัวเอง

---

## 📱 Compatibility

| Platform | Browser | รองรับ |
|----------|---------|--------|
| iPhone / iPad | Safari | ✅ |
| Mac | Chrome / Safari | ✅ |
| Android | Chrome | ✅ |

---

## ⚠️ หมายเหตุสำคัญ · Important Notes

**การสูญหายของข้อมูล** — localStorage จะหายถ้า:
- กด Clear History / Clear Website Data ใน Safari
- Reset iPhone
- iOS ล้าง inactive site data อัตโนมัติ (>7 วัน + ITP)

**แนะนำ:** Export JSON สำรองไว้เป็นประจำ หรือใช้ Supabase sync

---

*Personal project · ใช้งานส่วนตัว*

---

# Clinic-calendar — Claude guardrails

Read this before changing any storage, sync, or data-loading code in
`index.html`. It captures rules the human owner wants enforced across
every session.

## Pure-Supabase data policy (do not touch)

This app uses Supabase as the **only** durable store for app data.
Local-browser persistence is deliberately limited to a single key.

1. **Keep only `sb_session` in `localStorage`. Nothing else.**
   That single key stores the Supabase auth token. App data — clinics,
   shifts, hanging fees, proc/mach/trade lists — lives in the in-memory
   `appMemoryStore` only, and is populated from Supabase via
   `pullFromSupabase()` on load. Never write app data, settings, or
   any other value to `localStorage` (or `sessionStorage`, IndexedDB,
   cookies, Cache API, a service worker).

2. **If a change would make any code touch `localStorage` (other than
   `sb_session`) OR modify a database/storage/sync function, STOP and
   tell the human owner what you intend to do, and wait for the
   go-ahead before doing it.**

   The functions in scope include (non-exhaustive):
   `sbFetch`, `sbUpsert`, `sbSelect`, `sbDelete`,
   `appGetItem` / `appSetItem` / `appRemoveItem`, `appMemoryStore`,
   `clearCurrentUserCache`, `eachAppCacheKey`,
   `pullFromSupabase`, `syncLocalToSupabase`,
   and the per-domain savers: `saveData`, `saveClinics`,
   `saveProcList`, `saveMachList`, `saveTradeToList`, `saveHanging`.

### Why this rule exists

Silent local caching was deliberately removed in commit `ac8472a`
("use Supabase as app data source"). Reintroducing it would:
- Resurface stale data after the user edits on another device.
- Break the **fail-loud** save guarantees the rest of the code depends
  on (a failed Supabase write must be visible to the user, not
  papered over by a local cache that looks "saved").
- Make `restoreFromCloud`, `syncLocalToSupabase`, and the ↻ reload
  button behave unpredictably, since they assume in-memory state is
  the only thing that can diverge from Supabase.

The owner chose "Supabase-only, fail loud" explicitly. Treat that as
a standing decision, not a default to revisit.
