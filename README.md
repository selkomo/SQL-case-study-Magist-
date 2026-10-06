# SQL-Fallstudie — Magist

Soll Eniac einen Dreijahresvertrag mit Magist abschließen, um in den brasilianischen
Markt einzutreten?

Dieses Repository enthält die SQL-Arbeit hinter dieser Entscheidung. Wir haben einen
Auszug aus Magists Datenbank ohne Dokumentation erhalten und daraus die Antworten auf
die Fragen des Managements abgeleitet.

> **Hinweis:** Eniac und Magist sind **fiktive Unternehmen**. Es handelt sich um eine
> Übungs-Fallstudie aus der Weiterbildung Data Science & AI. Weder die Firmen noch die
> beschriebene Geschäftsbeziehung existieren. Der verwendete Datensatz ist
> Schulungsmaterial.

---

## Der Fall

Eniac ist ein spanischer Online-Marktplatz, spezialisiert auf Apple-Produkte und
hochwertiges Zubehör. Seit dem Börsengang drängen Investoren auf internationales
Wachstum, und der Vorstand will **innerhalb eines Jahres** nach Brasilien expandieren.

Eine eigene Lieferkette aufzubauen würde deutlich länger dauern. Magist, ein
brasilianisches SaaS-Unternehmen, bietet Auftragsmanagement, Lagerhaltung, Versand und
Kundenservice — mit bestehenden Verträgen zu Marktplätzen und der staatlichen Post.
Eniac würde weiterhin über die eigene Website unter eigener Marke verkaufen; Magist
übernimmt nur die Abwicklung im Hintergrund.

Im Unternehmen gibt es zwei offene Bedenken, die vor einer Unterschrift geklärt werden
müssen:

**1. Produktpassung.** Eniac verkauft hochwertige Technik. Ist Magist für dieses
Segment ein geeigneter Partner, oder ist die Plattform auf günstige Alltagsprodukte
ausgerichtet?

**2. Liefergeschwindigkeit.** Schnelle Lieferung ist zentral für Eniacs
Markenversprechen. Magists Postverträge sind günstig — aber sind die Lieferungen
schnell genug?

---

## Die Daten

Ein MySQL-Dump von Magists Datenbank, ohne Dokumentation. Alle Preise sind in Euro.

| Tabelle | Inhalt | Zeilen |
|---|---|---|
| `orders` | eine Zeile je Bestellung | 99.441 |
| `order_items` | eine Zeile je Artikel in einer Bestellung | 112.650 |
| `order_payments` | Zahlungen je Bestellung | 103.886 |
| `order_reviews` | Kundenbewertungen | 98.371 |
| `products` | Produktkatalog | 32.951 |
| `product_category_name_translation` | Kategorienamen PT → EN | 74 |
| `customers` | Kunden | 99.441 |
| `sellers` | Verkäufer | 3.095 |
| `geo` | Postleitzahlen, Orte, Bundesstaaten | 19.177 |

Abgedeckter Zeitraum: **September 2016 bis Oktober 2018**.

### Beziehungen

```
customers ──< orders ──< order_items >── products >── product_category_name_translation
                 │             │
                 │             └──> sellers
                 ├──< order_payments
                 └──< order_reviews

geo >── customers
geo >── sellers
```

---

## Inhalt des Repositories

| Datei | Inhalt |
|---|---|
| `01_day_magist_learning_the_basics.sql` | Erste Erkundung: Umfang, Bestellstatus, Wachstum, Produktkatalog, Preisspanne |
| `02_business_questions.sql` | Geschäftsfragen zu Produkten, Verkäufern und Lieferzeiten |

Jede Datei beginnt mit `USE magist;` und ist für sich lauffähig. Queries einzeln
ausführen, nicht die ganze Datei auf einmal.

---

## Analyse nachvollziehen

```bash
mysql -u root -p -e "CREATE DATABASE magist;"
mysql -u root -p magist < magist_dump.sql
```

Der Dump liegt nicht im Repository — er ist Kursmaterial.

In MySQL Workbench die gewünschte Query markieren und mit `Cmd+Shift+Enter` (macOS)
bzw. `Strg+Shift+Enter` (Windows) nur die Markierung ausführen.

---

## Getroffene Annahmen

Mehrere Fragen erforderten eigene Festlegungen. Wir dokumentieren sie, damit die
Zahlen nachvollziehbar und überprüfbar bleiben:

**Tech-Kategorien:** *(welche Kategorien wir als Technik gezählt haben)*

**Schwelle für „teuer":** *(ab welchem Preis und warum)*

**Tech-Verkäufer:** *(wann ein Verkäufer als Tech-Verkäufer gilt)*

---

## Ergebnisse

*(wird nach Abschluss der Analyse ergänzt — je ein kurzer Absatz pro Bedenken, mit
der Kennzahl, die ihn stützt)*

**Produktpassung:**

**Liefergeschwindigkeit:**

**Empfehlung:**

---

## Ergebnis des Projekts

Eine Präsentation von 3–4 Minuten mit einer klaren Empfehlung für oder gegen den
Vertrag, begründet aus den Daten und eigener Recherche zum brasilianischen Markt.

---

## Team

*(Namen)*

Teil der Weiterbildung Data Science & AI.
