# RISC-V Assembly Task Manager

Bu proje, RISC-V Assembly dilinde geliştirilmiş bir görev ve süreç yöneticisi uygulamasıdır. RARS (RISC-V Assembler and Runtime Simulator) kullanılarak yazılmış ve çalıştırılabilir.

## Özellikler

- Süreç listesi görüntüleme
- İsme göre süreç filtreleme
- PID ile süreç bulma
- Süreç sonlandırma
- Görev zamanlama sistemi
  - Tek seferlik görevler
  - Aralıklı görevler
  - Günlük görevler

## Dosya Yapısı

- `main.s`: Ana program ve menü işlevleri
- `process_manager.s`: Süreç yönetimi işlevleri
- `scheduler.s`: Görev zamanlama işlevleri

## Kurulum ve Çalıştırma

1. [RARS (RISC-V Assembler and Runtime Simulator)](https://github.com/TheThirdOne/rars) uygulamasını indirin.
2. RARS'ı açın ve tüm `.s` dosyalarını yükleyin.
3. "Assemble & Run" düğmesine tıklayarak programı çalıştırın.

## Uygulama Menüsü

```
==== RISC-V Task Manager ====
1. List all processes
2. Filter processes by name
3. Find process by PID
4. Terminate a process
5. Task scheduler
0. Exit
```

## Görev Zamanlayıcı

Görev zamanlayıcı, aşağıdaki özelliklere sahiptir:

- Yeni görev ekleme
- Görevleri listeleme
- Görev silme

Her görev için şu bilgiler saklanır:
- Komut (64 bayt)
- Tip (Tek seferlik, Aralıklı, Günlük)
- Yürütme zamanı
- Aralık (saniye)
- Aktif/Pasif durumu

## Uygulama Mimarisi

Bu uygulama modüler bir tasarıma sahiptir:

1. Ana modül (`main.s`): Kullanıcı arayüzü ve ana menü
2. Süreç yönetimi modülü (`process_manager.s`): Süreç listesi ve yönetimi
3. Görev zamanlayıcı modülü (`scheduler.s`): Zamanlama işlevleri

## Teknik Detaylar

- RISC-V Assembly dili kullanılmıştır
- Fonksiyon çağrıları için standart ABI kuralları takip edilmiştir
- Veri yapıları sabit boyutlu tamponlar kullanılarak uygulanmıştır
- Süreç verileri (bu demo sürümünde) simüle edilmiştir

## Kısıtlamalar

- Bu uygulama simüle edilmiş süreçlerle çalışır, gerçek işletim sistemi süreçlerine erişimi yoktur
- RARS simülatörü kısıtlamaları nedeniyle bazı sistem çağrıları taklit edilmiştir

## Katkıda Bulunanlar

- kappasutra - Proje geliştiricisi

## Lisans

MIT 