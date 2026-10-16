#set document(title: "Klasifikasi Credit Card Fraud dengan Ensemble Learning dan Resampling", author: "")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.3cm))
#set text(font: "Libertinus Serif", size: 10pt, lang: "id")
#set par(justify: true, leading: 0.65em, spacing: 0.7em)
#set heading(numbering: "1.")
#set table(stroke: 0.5pt + gray, inset: 5pt, align: center)

#align(center)[
  #text(size: 16pt, weight: "bold")[LAPORAN PRAKTIKUM DATA MINING]
  #v(0.4em)
  #text(size: 13pt, weight: "bold")[Klasifikasi Credit Card Fraud dengan Ensemble Learning dan Resampling]
  #v(1.5em)
  #align(left)[
    Nama: ........................................................\\
    NRP: ..........................................................\\
    Program Studi: ................................................
  ]
]

= Pendahuluan
Deteksi penipuan transaksi kartu kredit (*credit card fraud detection*) merupakan masalah klasifikasi biner yang menantang karena jumlah transaksi fraud jauh lebih sedikit dibandingkan transaksi normal. Ketidakseimbangan kelas dapat menyebabkan model cenderung memprediksi kelas mayoritas, sehingga *accuracy* yang tinggi belum tentu menunjukkan kemampuan mendeteksi fraud. Praktikum ini membandingkan Random Forest dan Gradient Boosting, baik tanpa resampling maupun dengan beberapa metode penanganan *class imbalance*.

Tujuan eksperimen adalah mengidentifikasi distribusi kelas, membagi data menjadi data latih dan data uji dengan rasio 80:20 menggunakan stratifikasi, membandingkan metode resampling pada data latih, serta mengevaluasi hasil menggunakan precision, recall, F1-score, ROC-AUC, PR-AUC, dan *confusion matrix*.

= Dataset dan Eksplorasi Data
Dataset `creditcard.csv` memiliki 284.807 baris dan 31 kolom. Atribut terdiri atas `Time`, `Amount`, fitur hasil transformasi PCA `V1` sampai `V28`, serta `Class` sebagai label target. `Class` bernilai 0 untuk transaksi non-fraud dan 1 untuk transaksi fraud. Berdasarkan pemeriksaan notebook, tidak ditemukan nilai kosong pada kolom-kolom dataset.

Distribusi kelas terdiri atas 284.315 transaksi Class 0 (sekitar 99,83%) dan 492 transaksi Class 1 (sekitar 0,17%). Perbandingan yang sangat timpang ini berarti transaksi fraud hanya sebagian kecil dari keseluruhan data.

#align(center)[
  #image("distribusi_class.png", width: 82%)
  #text(size: 9pt)[*Gambar 1.* Distribusi jumlah transaksi pada masing-masing kelas.]
]

Jika model selalu memprediksi seluruh transaksi sebagai non-fraud, accuracy-nya tetap sekitar 99,83%, tetapi model gagal mendeteksi fraud. Oleh karena itu, accuracy tidak cukup dijadikan metrik utama.

= Praproses dan Rancangan Eksperimen
Atribut `Class` dipisahkan sebagai target (`y`), sedangkan seluruh atribut lainnya digunakan sebagai fitur (`X`). Dataset kemudian dibagi menggunakan `train_test_split` dengan `test_size=0.2`, `random_state=42`, dan `stratify=y`. Stratifikasi mempertahankan proporsi kelas secara kurang lebih sama pada data latih dan data uji.

Resampling diterapkan hanya pada data latih. Data uji tidak diubah agar evaluasi merepresentasikan distribusi kelas yang asli. Metode yang dibandingkan adalah tanpa resampling, RandomOverSampler, SMOTE, ADASYN, BorderlineSMOTE, RandomUnderSampler, NearMiss, SMOTEENN, dan SMOTETomek.

Dua model ensemble digunakan: Random Forest dengan 100 pohon dan Gradient Boosting dengan 100 estimator, `learning_rate=0.1`, serta `max_depth=3`. Parameter dasar dibuat tetap pada seluruh percobaan agar perbandingan awal berfokus pada pengaruh model dan metode resampling, bukan hasil tuning.

= Metrik Evaluasi
*Precision* mengukur proporsi prediksi fraud yang benar-benar fraud, sedangkan *recall* mengukur proporsi seluruh transaksi fraud yang berhasil ditemukan. F1-score merupakan rata-rata harmonik precision dan recall. ROC-AUC mengukur kemampuan pemeringkatan kelas pada berbagai threshold, sementara PR-AUC (Average Precision pada implementasi ini) merangkum trade-off precision dan recall. Untuk kelas fraud yang sangat langka, PR-AUC, recall, dan F1-score memberikan informasi yang lebih relevan daripada accuracy saja.

= Hasil dan Pembahasan
Pada eksperimen ini, hasil F1-score tertinggi diperoleh Random Forest tanpa resampling, yaitu 0,8743, dengan precision 0,9412, recall 0,8163, ROC-AUC 0,9630, dan PR-AUC 0,8734. Hasil ini menunjukkan bahwa pada pembagian data dan parameter yang digunakan, Random Forest mampu mencapai keseimbangan precision-recall yang baik meskipun dilatih dengan distribusi asli.

Untuk Random Forest, BorderlineSMOTE menghasilkan precision tertinggi sebesar 0,9625, tetapi recall-nya 0,7857 dan F1-score 0,8652, sedikit di bawah baseline. SMOTE menghasilkan recall 0,8265 dan F1-score 0,8265. SMOTEENN menghasilkan recall lebih tinggi, 0,8673, tetapi precision turun menjadi 0,7870 sehingga F1-score menjadi 0,8252. Artinya, peningkatan kemampuan menemukan fraud dapat disertai peningkatan false positive.

Pada Gradient Boosting, BorderlineSMOTE merupakan hasil terbaik berdasarkan F1-score, yaitu 0,7289, dengan precision 0,6457 dan recall 0,8367. Tanpa resampling, model memperoleh precision 0,5294 tetapi recall hanya 0,1837 dan F1-score 0,2727. Metode oversampling lainnya umumnya meningkatkan recall hingga 0,8980, tetapi precision turun ke sekitar 0,16–0,19. Hal ini menandakan banyak transaksi normal ikut ditandai sebagai fraud pada threshold default.

#align(center)[
  #image("perbandingan_f1_pr_auc.png", width: 100%)
  #text(size: 9pt)[*Gambar 2.* Perbandingan metrik hasil eksperimen pada model dan metode resampling.]
]

= Ringkasan Hasil Eksperimen
#table(
  columns: (1.25fr, 1.5fr, 0.85fr, 0.75fr, 0.75fr, 0.8fr, 0.75fr),
  table.header([*Model*], [*Resampling*], [*Precision*], [*Recall*], [*F1-score*], [*ROC-AUC*], [*PR-AUC*]),
  [Random Forest], [No Resampling], [0.9412], [0.8163], [0.8743], [0.9630], [0.8734],
  [Random Forest], [BorderlineSMOTE], [0.9625], [0.7857], [0.8652], [0.9572], [0.8523],
  [Random Forest], [SMOTETomek], [0.8317], [0.8571], [0.8442], [0.9693], [0.8729],
  [Gradient Boosting], [BorderlineSMOTE], [0.6457], [0.8367], [0.7289], [0.9601], [0.7366],
  [Gradient Boosting], [SMOTEENN], [0.1888], [0.8980], [0.3121], [0.9795], [0.7804],
)

Undersampling menghasilkan recall tinggi tetapi precision sangat rendah. Misalnya, Random Forest dengan NearMiss memiliki recall 0,9388, tetapi precision hanya 0,0049 dan F1-score 0,0098. Model berhasil menemukan banyak fraud, tetapi juga menghasilkan sangat banyak false positive. Selain itu, undersampling menyisakan hanya 788 sampel training, sehingga sebagian besar informasi dari kelas mayoritas dibuang.

Perlu dicatat bahwa ROC-AUC yang tinggi tidak selalu sejalan dengan F1-score yang tinggi. ROC-AUC menilai kemampuan pemeringkatan pada banyak threshold, sedangkan precision, recall, dan F1-score di atas dihitung pada threshold prediksi default model. Untuk aplikasi nyata, threshold dapat dipilih berdasarkan biaya false negative dan false positive, tetapi penentuannya harus dilakukan menggunakan data validasi, bukan test set.

= Kesimpulan
Berdasarkan hasil eksperimen awal, Random Forest tanpa resampling menjadi konfigurasi terbaik berdasarkan F1-score (0,8743) dan memiliki precision yang tinggi (0,9412), dengan recall 0,8163. Dengan demikian, resampling tidak otomatis meningkatkan performa; dampaknya bergantung pada algoritma dan metrik yang dipilih. BorderlineSMOTE merupakan konfigurasi terbaik untuk Gradient Boosting pada F1-score (0,7289), sedangkan SMOTEENN pada Gradient Boosting memberi recall tinggi tetapi precision rendah.

Untuk pengembangan lebih lanjut, eksperimen dapat diperkuat melalui cross-validation pada data training, tuning hyperparameter, analisis confusion matrix, dan penentuan threshold berdasarkan kebutuhan operasional. Evaluasi akhir tetap harus menggunakan test set dengan distribusi asli yang tidak pernah di-resample.

= Catatan
Angka pada laporan ini diambil dari output notebook yang diberikan. Hasil merupakan eksperimen awal dengan parameter dasar dan satu pembagian train-test, sehingga tidak boleh dianggap sebagai jaminan performa pada data baru. Lengkapi identitas penulis pada bagian awal sebelum dikumpulkan.

= Lampiran: Confusion Matrix Model Terbaik
Untuk konfigurasi Random Forest tanpa resampling, nilai precision 0,9412 dan recall 0,8163 konsisten dengan sekitar 80 transaksi fraud yang terdeteksi benar (*true positive*), 18 fraud yang terlewat (*false negative*), dan 5 transaksi normal yang salah ditandai sebagai fraud (*false positive*). Dengan 56.864 transaksi non-fraud pada test set, *true negative* berjumlah sekitar 56.859.

#table(
  columns: (1.6fr, 1fr, 1fr),
  table.header([], [*Prediksi 0 (Non-fraud)*], [*Prediksi 1 (Fraud)*]),
  [*Aktual 0 (Non-fraud)*], [56.859 (TN)], [5 (FP)],
  [*Aktual 1 (Fraud)*], [18 (FN)], [80 (TP)],
)

Angka confusion matrix di atas direkonstruksi dari metrik yang tercetak dan jumlah data test hasil stratifikasi; untuk pelaporan final, disarankan menjalankan `confusion_matrix(y_test, y_pred)` pada notebook dan mencocokkan angka persisnya. TN dihitung berdasarkan total data test dan jumlah kelas yang tersirat pada pembagian stratifikasi.
