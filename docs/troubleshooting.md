# Troubleshooting log

Real failures, what I found, and what I changed afterward.

## 1. No local display when remote access was down

**Symptom.** Remote access to the server went unavailable and I needed a screen to see what was happening.

**Cause.** The server's Quadro 5000 had video outputs that didn't match the HDMI monitor I use for testing, so plugging in a display meant hunting for adapters every time.

**Fix.** Replaced it with a GeForce GT 1030, which has an HDMI port.

**Lesson.** Plan for the failure mode where the network is the thing that's broken. A server you can only reach over the network is a server you can lose.

## 2. Power supply failure

**Symptom.** I tried to turn the server on and the power button just kept blinking orange. It wouldn't boot.

**Diagnosis.** I looked up the blinking-orange code, and it pointed to a power supply failure. I removed the old unit to replace it.

**Fix.** Bought a new standard ATX 600 W power supply, installed it, and everything worked.

**Lesson.** Read the diagnostic codes before guessing. The blink pattern told me where to look, so I replaced one part instead of trial-and-erroring several.

## 3. Private search engine returning no results

**Symptom.** Every query on my self-hosted SearXNG returned "No results found," with a list of engines marked suspended: rate-limited, CAPTCHA, or access denied.

**Diagnosis.** The logs showed the upstream engines refusing my server, with HTTP 429 (too many requests), 403, and CAPTCHA redirects. Counting errors per engine showed DuckDuckGo failing most often. So SearXNG itself was healthy; the engines it queries were blocking it, and each new search made it retry them.

**Fix.** I disabled the engines that kept refusing me (DuckDuckGo, Startpage, Brave, Wikidata), enabled ones that tolerate scraping (Bing, Mojeek, Yahoo) in `settings.yml`, and restarted to clear the suspensions.

**Lesson.** Read the failure before touching config: the error messages named the problem. It also showed why a public search instance needs access control, since every stranger's query is sent to those engines from my IP address.
