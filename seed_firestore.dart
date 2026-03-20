import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final songs = [
    {
      'title': 'Cảm Ơn Anh Độ (Russian Hardbass Version)',
      'artist': '#Hwungg🥀',
      'url': 'https://files.catbox.moe/36782y.mp3',
      'thumbnail': 'https://files.catbox.moe/olou5w.png',
      'genre': 'EDM',
    },
    {
      'title': 'Yêu Nắm (R&B version)',
      'artist': 'BigDaddy & Emily',
      'url': 'https://files.catbox.moe/ok1bbd.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/pnpDcarj71tsnvyOfRpyhMHY6UEc3CwEWHaIJdsgN1Zr-xs3_Gk7j2W-YNv3FOWPlDrG5mfrpGRUKJ4lqA=w544-h544-l90-rj',
      'genre': 'R&B',
    },
    {
      'title': 'Anh Thôi Nhân Nhượng (Cover)',
      'artist': 'Kiều Chi',
      'url': 'https://files.catbox.moe/97fent.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/nkRviMytOWKC6N10LOOAZKrDm0yoicTqtub5fKnybOWHxOGW0oG_LmCpZVaNFDLIpYyMMoMW8VtXhnUI=w544-h544-l90-rj',
      'genre': 'Ballad',
    },
    {
      'title': 'E Là Không Thể (Chốn Tìm Show)',
      'artist': 'Anh Quân Idol',
      'url': 'https://files.catbox.moe/tdnele.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/tQL6mG_Wrpjk-Knba6Yz_cBhFuJvHewt-rlLDmMaDrLY1TIrX_zaeESKKJ5DdK3yCv0lE8IVXv1_oTn8=w544-h544-l90-rj',
      'genre': 'Ballad',
    },
    {
      'title': 'Cảm Ơn Người Đã Thức Cùng Tôi (Original Soundtrack)',
      'artist': 'Phùng Khánh Linh & 30 Pictures',
      'url': 'https://files.catbox.moe/qj0v4b.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/XYvvkDk8QH7On9v6f-BvbVYm_gWPkB91_BCqnlS2kXbVQY_8tw_Gz3NcltF8CfFMoyDLuaj_QXGvMUqs=w544-h544-l90-rj',
      'genre': 'Pop',
    },
    {
      'title': 'ANH LÀ THẰNG TỒI',
      'artist': 'Phùng Khánh Linh',
      'url': 'https://files.catbox.moe/oxc4hj.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/3dzyHWWqWcs40_ujeyTS3ErPvfMuEB8vXNKW8IAJHJX8tUCQpgj66sxJ20nnjA0TsB7snowbXraTlVc=w544-h544-l90-rj',
      'genre': 'Pop',
    },
    {
      'title': 'Hẹn Hò Nhưng Không Yêu (Thazh x Đông Remix)',
      'artist': 'Wendy Thảo',
      'url': 'https://files.catbox.moe/e3gz2z.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/QfrteO2P7xzMR_2l_-r0CgJZM9NiRWTpO0EZqOrd4SGI-pyPC6lWYiphv8qNxgrD4XWAzsOF7CUceX4=w544-h544-l90-rj',
      'genre': 'Pop',
    },
    {
      'title': 'E Là Đôn Chề',
      'artist': 'COOLKID & BAN',
      'url': 'https://files.catbox.moe/49vfv8.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/ZpH4zHRqObXT2IsrV0j063b_5Mo_2tlr7h_zGiNEgXcqNGyxU0kEMokpwUqi5FlDk5TcI8USabA4Ql0=w544-h544-l90-rj',
      'genre': 'Pop',
    },
    {
      'title': 'Lệ Lưu Ly',
      'artist': 'Vũ Phụng Tiên, DT Tập Rap & Drum7',
      'url': 'https://files.catbox.moe/0ewa12.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/yjsUPXXkALfLUC5lFWahsMok88QN0SKZ7cGuoh8DU1xVKvBmfvjk283Za1_JVMBmLjIQ0zKGq7kf3SE=w544-h544-l90-rj',
      'genre': 'Pop',
    },
    {
      'title': 'Hẹn Lần Sau',
      'artist': 'MAYDAYs',
      'url': 'https://files.catbox.moe/bflrrh.mp3',
      'thumbnail': 'https://lh3.googleusercontent.com/lKXssJOS3o1KDKETW43E1OJenGXCXovsey3qByox5kBtWtcUU9jwUA7eNm95iVv9GD8KZo_VB-9W5d0=w544-h544-l90-rj',
      'genre': 'Pop',
    },
  ];

  for (var song in songs) {
    await FirebaseFirestore.instance.collection('songs').add(song);
    print('Added: ${song['title']}');
  }
  print('Done!');
}
