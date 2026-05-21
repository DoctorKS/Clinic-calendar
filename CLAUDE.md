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
- ปุ่ม ↻ = โหลดแอปเวอร์ชันล่าสุดจาก server + ดึงข้อมูลใหม่จาก Supabase
  (จะเปลี่ยนเป็น cache-only ใน Step ถัดไป)

**iOS Safari ITP** — Safari อาจ wipe localStorage หลังไม่ได้เปิดแอป ~7 วัน
ข้อมูลใน Supabase ยังอยู่ครบ; เปิดแอปแล้ว pull ลงมาใหม่อัตโนมัติ

**แนะนำ:** Export JSON สำรองไว้บางครั้ง เผื่อ Supabase project หาย

---

*Personal project · ใช้งานส่วนตัว*

---

# Clinic-calendar — Claude guardrails

Read this before changing any storage, sync, or data-loading code in
`index.html`. It captures rules the human owner wants enforced across
every session.

## Local-First Architecture (standing policy)

This app writes to `localStorage` first, updates the UI immediately, and
syncs to Supabase in the background. Reaching the network must **never**
block what the user sees. Supabase is the durable cloud copy; localStorage
is the source of truth at write time and the cache at read time.

This supersedes the prior "Pure-Supabase data policy" (commit `ac8472a` +
follow-ups). The fail-loud-on-Supabase-error pattern is downgraded from a
hard contract to a fallback signal — failed writes go into a retry queue,
not a blocking error.

### Core principle

> Write to local first → show UI immediately → sync to server in background.
> **Never block UI on network.**

### Write path

```
User action
    ↓
Write to localStorage (instant, synchronous)
    ↓
Update UI immediately ← user sees result right away
    ↓
Queue operation in sync queue (also in localStorage)
    ↓
Background: push to Supabase (async, non-blocking)
    ↓
On success → mark as SYNCED
On failure → keep in queue → retry with backoff
```

### The sync queue — most important piece

Every write enters a pending queue stored in `localStorage` under the key
`sync_queue` before it ever hits Supabase. Each queue entry:

```javascript
{
  id: uuid,                              // entry id, not record id
  operation: 'upsert' | 'delete',
  table: 'shifts' | 'clinics' | …,
  payload: { … },                        // the row
  timestamp: Date.now(),
  retryCount: 0,
  state: 'PENDING' | 'SYNCING' | 'SYNCED' | 'CONFLICT' | 'ERROR'
}
```

On reconnect / app open → flush the queue → Supabase receives all pending
ops in order. The queue survives offline, page reload, app crash, and
device reboot because it lives in `localStorage`.

### Conflict resolution — Last Write Wins by `updated_at`

```javascript
if (localRecord.updated_at > serverRecord.updated_at) {
  // push local to server
} else {
  // pull server to local
}
```

Sufficient for single-user / multi-device. Do not introduce CRDTs, merge,
or operational transforms without owner approval — they are not warranted
for this workload.

### Sync state per record

- `PENDING` → written locally, not yet sent
- `SYNCING` → currently being sent
- `SYNCED`  → confirmed by server
- `CONFLICT` → server has newer version
- `ERROR`   → failed after N retries

### Retry policy — exponential backoff

```
Attempt 1: immediate
Attempt 2: 2 seconds
Attempt 3: 4 seconds
Attempt 4: 8 seconds
Attempt 5: 16 seconds
After 5 → move to dead-letter queue → notify user via fail-loud banner
```

### What each layer protects against

```
User types        → localStorage write (instant)       prevents data loss
Network drops     → sync queue persists locally        survives offline
App crash         → queue survives in localStorage     crash safe
Server error      → retry with exponential backoff     eventually consistent
Device reset      → server has full copy               recoverable
Conflict          → updated_at comparison              deterministic
```

### Current state vs. target state

- ✅ Background push to Supabase exists (`syncLocalToSupabase`, now
  flushes via the sync queue)
- ✅ Pull on open exists (`pullFromSupabase`)
- ✅ localStorage cache of app data (per-user write-through, Step 1
  of the migration — see `_appCachePrefix`, `hydrateFromLocalCache`)
- ✅ Sync queue (Step 2 of the migration — see `_syncQueueKey`,
  `enqueue`, `flushSyncQueue`; all 6 savers enqueue instead of awaiting
  Supabase; UI never blocks)
- ✅ Online-event auto-flush (`window.addEventListener('online', ...)`)
- ❌ No `updated_at` comparison on pull (Step 4)
- ❌ No retry-with-exponential-backoff yet — current retry is "next
  trigger" with fail-fast on first failure per flush (Step 3)
- ❌ No conflict-resolution UI for CONFLICT state (Step 4)

The migration is in progress. Current code reflects the prior policy in
many places. Treat this section as the **target** that all new edits
must move toward, not the current implementation.

### Standing instruction to Claude / Codex

Before changing any storage, sync, or data-loading code in `index.html`:

1. **Read this section.**
2. **Confirm the change moves toward local-first**, not away from it.
   Adding a localStorage cache, the sync queue, retry logic, or
   `updated_at` comparison — all good. Removing localStorage usage,
   blocking the UI on a Supabase call, or silently dropping a failed
   write — all bad.
3. **If the change touches the sync queue shape, retry policy, conflict
   resolution, or the on-disk localStorage cache shape, STOP and tell
   the human owner what you intend to do, and wait for the go-ahead.**
   These are the contract; changing them mid-migration causes data
   corruption.
4. **Never delete a `localStorage` app-data key without a migration path.**
   Users have data in there; dropping it loses real shifts and real
   income.
5. The functions in scope of this rule include (non-exhaustive):
   `sbFetch`, `sbUpsert`, `sbSelect`, `sbDelete`,
   `appGetItem` / `appSetItem` / `appRemoveItem`, `appMemoryStore`,
   `pullFromSupabase`, `syncLocalToSupabase`,
   the per-domain savers (`saveData`, `saveClinics`, `saveProcList`,
   `saveMachList`, `saveTradeToList`, `saveHanging`),
   and any future `enqueue`, `flushSyncQueue`, `resolveConflict`,
   `retryWithBackoff` introduced during the migration.

### Why this rule exists

The "Supabase-only, fail loud" approach (commit `ac8472a`) had a real
problem: when a write fails (network glitch, Supabase rate limit, expired
token), the user sees an error and the data is gone. There is no retry
path. Real-world mobile use on iPhone Safari hits this — flaky LTE in a
clinic, captive-portal wifi, sleeping device while saving. The local-first
+ sync-queue model fixes this without giving up cloud sync: localStorage
absorbs the write instantly, the queue absorbs the network unreliability,
and Supabase remains the durable cross-device source.

This is a deliberate reversal of `ac8472a`. Treat it as a standing
decision, not a default to revisit.
