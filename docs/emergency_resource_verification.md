# Emergency resource verification (Batch 11)

**Last verified:** 26 August 2026
**Scope:** every emergency number, helpline resource, and international line in the app.

## 1. Nigeria — national number

| Resource | Number | Status | Source | Verified |
|---|---|---|---|---|
| National emergency line (all states) | **112** | Toll-free, any network; FEC-approved universal number; ~35 NCC Emergency Communications Centres operational; FG moved in July 2026 to make 112 the single national number | NCC press release (ncc.gov.ng); Daily Post, 9 Jul 2026; ConsumerConnect, 20 Aug 2026 | 26 Aug 2026 |
| Lagos state line (top card) | **767** | Listed for Lagos alongside 112 | NEMSAS list via ConsumerConnect, 20 Aug 2026; Mental Health Lagos emergency services page | 26 Aug 2026 |

## 2. Nigeria — state call-centre numbers (all 36 states + FCT)

Source: **NEMSAS state emergency call-centre list, published 19 August 2026**
(reported by ConsumerConnect, 20 August 2026: "Government adopts NCC's 112 emergency
number for medical exigencies, releases state numbers (Full List)").
Every number in `lib/utils/constants.dart` was checked against that list on 26 August 2026.
States added in Batch 11 (previously missing): Cross River, Delta, Kano, Katsina, Kebbi,
Kogi, Kwara, Lagos, Nasarawa, Ogun, Ondo, Oyo, Plateau, Rivers, Sokoto.

| State | Number shown in app | NEMSAS list (19 Aug 2026) | Result |
|---|---|---|---|
| Abia | 08000000800 | 112, 08000000800 | ✅ match |
| Adamawa | 07011111443 (also 1755) | 112, 1755, 07011111443 | ✅ match |
| Akwa Ibom | 08000022322 (also 08000022422) | 112, 08000022322, 08000022422 | ✅ match |
| Anambra | 08002200008 (also 5111) | 112, 5111, 08002200008 | ✅ match |
| Bauchi | 07038636433 | 112, 07038636433 | ✅ match |
| Bayelsa | 08002200223 | 112, 08002200223 | ✅ match |
| Benue | — (not operational) | "Not Operational" | ✅ match |
| Borno | 08000000033 | 112, 08000000033 | ✅ match |
| Cross River | 112 | 112 | ✅ match (added) |
| Delta | 07041008130 (also 07041008131) | 112, 07041008130, 07041008131 | ✅ match (added) |
| Ebonyi | 08086446891 (also 08086445736) | 112, 08086446891, 08086445736 | ✅ match |
| Edo | 09037999871 (also 739) | 112, 739, 09037999871 | ✅ match |
| Ekiti | 08000606606 | 112, 08000606606, 08111111-22..55 | ✅ match |
| Enugu | 09074996090 (also 07066466429) | 112, 09074996090, 07066466429 | ✅ match |
| Gombe | 07033825646 | 112, 07033825646 | ✅ match |
| Imo | — (not operational) | "Not Operational" | ✅ match |
| Jigawa | 112 | 112 | ✅ match |
| Kaduna | 08064111599 | 112, 08064111599 | ✅ match |
| Kano | 09019999920 (also 09049999914) | 112, 09019999920, 09049999914 | ✅ match (added) |
| Katsina | 112 | 112 | ✅ match (added) |
| Kebbi | 112 | 112 | ✅ match (added) |
| Kogi | 112 | 112 | ✅ match (added) |
| Kwara | 09062010001 (also 09062010002) | 112, 09062010001, 09062010002 | ✅ match (added) |
| Lagos | 767 (also 112) | 112, 767 | ✅ match (added) |
| Nasarawa | 08144911269 | 112, 08144911269 | ✅ match (added) |
| Niger | 08022422953 (also 08155577513) | 112, 08022422953, 08155577513 | ✅ match (secondary number added) |
| Ogun | 08112000033 | 112, 08112000033 | ✅ match (added) |
| Ondo | 08055300300 | 112, 08055300300 | ✅ match (added) |
| Osun | 08111110532 (also 08111110561) | 112, 08111110532, 08111110561 | ✅ match |
| Oyo | 615 (also 112) | 112, 615 | ✅ match (added) |
| Plateau | 09136982496 | 112, 09136982496 | ✅ match (added) |
| Rivers | 09040222281 (also 09040222283, 09040222285) | 112, 09040222281/283/285 | ✅ match (added) |
| Sokoto | 07045963318 (also 07071765080) | 112, 07045963318, 07071765080 | ✅ match (added) |
| Taraba | 07041122777 (also 07041100777) | 112, 07041122777, 07041100777 | ✅ match |
| Yobe | 09169981792 (also 08000090009) | 112, 09169981792, 08000090009 | ✅ match (secondary number added) |
| Zamfara | 112 | 112 | ✅ match |
| FCT Abuja | 09157892931 (also 09157892932) | 112, 09157892931, 09157892932 | ✅ match |

**Unlisted-state behaviour (Batch 11 task 3):** all 36 states + FCT are now listed; the
picker helper text ("If your state is not listed, call 112") and the prominent
"National Emergency Line — Call 112" card remain as the safety net.

## 3. International emergency numbers

Verified 26 August 2026 against standard national emergency-number references
(911.gov, GOV.UK, government of Australia/NZ/India/Japan/Singapore published numbers):

| Entry in app | Standard number | Result |
|---|---|---|
| European Union — 112 | 112 (EU-wide emergency number) | ✅ |
| United States / Canada — 911 | 911 | ✅ |
| United Kingdom / Ireland — 999 (112 also works) | 999 (112 works on mobile networks) | ✅ |
| Australia — 000 | 000 | ✅ |
| New Zealand — 111 | 111 | ✅ |
| South Africa — 10111 (ambulance 10177) | 10111 general / 10177 ambulance | ✅ |
| India — 112 | 112 (Dial 112 national emergency service) | ✅ |
| Japan — 110 (ambulance/fire 119) | 110 police / 119 fire-ambulance | ✅ |
| Singapore — 999 | 999 | ✅ |

## 4. External helpline resource

| Resource | URL | Result | Verified |
|---|---|---|---|
| Find a Helpline (international crisis-helpline directory, run with the 988 Suicide & Crisis Lifeline) | https://findahelpline.com/ | Live; indexed and described as "global vetted directory of helplines, hotlines and crisis lines" | 26 Aug 2026 (search-index check; direct fetch blocked from the sandbox — confirm it opens on the competition phone during the 7E/12 device pass) |

## 5. Professional listings (Batch 11 task 6)

- Directory listings are prototype data loaded from Firestore.
- **Batch 11 fix applied:** the directory now shows a persistent "Demo data" banner —
  "the professionals shown in this prototype are sample listings for demonstration —
  not verified providers."

## 6. Remaining Batch 11 items (honest status)

- **Device pass (needs a phone):** test every `tel:` and `sms:` action (37 state
  entries, international section, trusted contacts) and that `findahelpline.com`
  opens in the in-app browser — scheduled with the Batch 12 device matrix.
- **Qualified mental-wellness reviewer** for CBT/meditation/breathing/AI/emergency
  wording: not available at prototype stage; wording was written to the app's own
  safety guidelines (no diagnosis, no crisis language for positive moods, crisis
  content routed to human support). Documented as a known limitation.
- **Terms/Privacy wording:** reviewed for accuracy against what the app actually
  stores (owner-only Firestore data, transparent AI, in-app + web deletion).
- **Re-verify before public release:** state call-centre numbers and operational
  status change (NEMSAS's own list changed between 2024 and 2026); re-run this
  verification against a fresh NEMSAS/NCC release before any public build.
