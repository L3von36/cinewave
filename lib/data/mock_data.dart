import 'package:flutter/material.dart';

import 'models/movie.dart';

/// Public-domain demo streams used by the player. If none of these load
/// (e.g. offline), the player gracefully falls back to simulated playback.
const List<String> kDemoStreams = [
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
];

/// Deterministically pick a demo stream for a given title id.
String streamFor(String id) =>
    kDemoStreams[id.hashCode.abs() % kDemoStreams.length];

/// Genre -> [top, bottom] gradient palette used by the procedural posters.
const Map<String, List<Color>> _palettes = {
  'Sci-Fi': [Color(0xFF6C7BFF), Color(0xFF141B4D)],
  'Action': [Color(0xFFFF5A5F), Color(0xFF4D0F1E)],
  'Thriller': [Color(0xFF9E2B4E), Color(0xFF1C0F2E)],
  'Animation': [Color(0xFFFFA94D), Color(0xFF7A3E12)],
  'Drama': [Color(0xFF2FB39B), Color(0xFF0C2E33)],
  'Adventure': [Color(0xFF7BC950), Color(0xFF1E3D14)],
  'Mystery': [Color(0xFF7A8CA5), Color(0xFF1A2230)],
  'Documentary': [Color(0xFF35B0C9), Color(0xFF0E2F3B)],
  'Fantasy': [Color(0xFF9B5DE5), Color(0xFF2A1B54)],
  'Romance': [Color(0xFFFF6FA5), Color(0xFF4A1030)],
  'Comedy': [Color(0xFFFFD166), Color(0xFF4D3A0E)],
  'Horror': [Color(0xFF4A3F6B), Color(0xFF0D0A14)],
};

Season _s(int number, List<String> titles) => Season(
      number: number,
      episodes: [
        for (var i = 0; i < titles.length; i++)
          Episode(
            number: i + 1,
            title: titles[i],
            minutes: 34 + (i * 7 + number * 3) % 19,
          ),
      ],
    );

Movie _m({
  required String id,
  required String title,
  required String tagline,
  required String synopsis,
  required int year,
  required double rating,
  required int minutes,
  required List<String> genres,
  String age = 'PG-13',
  List<String> cast = const [],
  bool series = false,
  List<Season> seasons = const [],
  bool trending = false,
  bool isNew = false,
  String quality = '4K HDR',
}) {
  final p = _palettes[genres.first] ??
      const [Color(0xFF7C6CFF), Color(0xFF141B4D)];
  return Movie(
    id: id,
    title: title,
    tagline: tagline,
    synopsis: synopsis,
    year: year,
    rating: rating,
    runtimeMinutes: minutes,
    genres: genres,
    ageRating: age,
    cast: cast,
    isSeries: series,
    seasons: seasons,
    isTrending: trending,
    isNew: isNew,
    quality: quality,
    posterTop: p[0],
    posterBottom: p[1],
  );
}

/// Continue-watching entries seeded on first launch (id -> progress 0..1).
const Map<String, double> kInitialProgress = {
  'aurora-protocol': 0.42,
  'the-last-lighthouse': 0.15,
  'nightsharp': 0.78,
};

const String kProgressSeededKey = 'progress_seeded';

/// Genres surfaced as dedicated rails on the Home screen.
const List<String> kHomeGenres = ['Sci-Fi', 'Thriller', 'Drama'];

/// The CineWave demo catalog — 28 original titles.
final List<Movie> kMovies = [
  _m(
    id: 'aurora-protocol',
    title: 'Aurora Protocol',
    tagline: 'Signal found. Silence broken.',
    synopsis:
        'A deep-space listening post decodes a message from Earth — sent forty years in the future.',
    year: 2025,
    rating: 9.1,
    minutes: 52,
    genres: ['Sci-Fi', 'Thriller'],
    age: 'TV-MA',
    cast: ['Maren Solis', 'Dev Kapoor', 'Iris Halvorsen', 'Tomás Reyes'],
    series: true,
    seasons: [
      _s(1, ['Cold Open', 'Carrier Wave', 'The Long Echo', 'Dead Air', 'Ground Truth', 'Interference']),
      _s(2, ['Resonance', 'The Second Voice', 'Parallax', 'Eventide', 'Answer']),
    ],
    trending: true,
    isNew: true,
  ),
  _m(
    id: 'the-last-lighthouse',
    title: 'The Last Lighthouse',
    tagline: 'Some lights refuse to go out.',
    synopsis:
        'A retired keeper returns to a remote lighthouse and finds the lamp still burning — though no one has tended it for a decade.',
    year: 2024,
    rating: 8.6,
    minutes: 128,
    genres: ['Drama', 'Mystery'],
    age: 'PG-13',
    cast: ['Eleanor Voss', 'Samuel Adeyemi', 'Grete Lindqvist'],
    trending: true,
  ),
  _m(
    id: 'neon-tide',
    title: 'Neon Tide',
    tagline: 'The city surfs the current.',
    synopsis:
        'In a flooded megacity, a courier smuggles memories in bioluminescent ampoules — until one of them starts talking back.',
    year: 2025,
    rating: 7.8,
    minutes: 112,
    genres: ['Sci-Fi', 'Action'],
    cast: ['Kaia Ren', 'Oswald Mbeki', 'Lian Zhou', 'Ferran Costa'],
    isNew: true,
  ),
  _m(
    id: 'paper-moons',
    title: 'Paper Moons',
    tagline: 'Two hearts, one orbit.',
    synopsis:
        'A planetarium projectionist and a night-shift astronomer keep meeting at the exact minute the stars switch on.',
    year: 2023,
    rating: 7.9,
    minutes: 104,
    genres: ['Romance', 'Drama'],
    age: 'PG',
    cast: ['June Marlowe', 'Andrei Sokolov', 'Priya Nair'],
  ),
  _m(
    id: 'kilometer-zero',
    title: 'Kilometer Zero',
    tagline: 'Every road starts somewhere.',
    synopsis:
        'Five strangers walk a forgotten highway to deliver a letter no post office would take.',
    year: 2024,
    rating: 7.5,
    minutes: 118,
    genres: ['Adventure'],
    cast: ['Rosa Delgado', 'Ben Okafor', 'Yuki Tanabe', 'Magnus Eriksson'],
  ),
  _m(
    id: 'the-glass-orchestra',
    title: 'The Glass Orchestra',
    tagline: 'Music made from broken things.',
    synopsis:
        'Inside the workshop where blind artisans rebuild shattered instruments into a one-of-a-kind orchestra.',
    year: 2023,
    rating: 8.2,
    minutes: 86,
    genres: ['Documentary'],
    age: 'PG',
    cast: ['Narrated by Adaeze Obi', 'Conductor Lior Amit'],
    isNew: true,
  ),
  _m(
    id: 'saltwater-kings',
    title: 'Saltwater Kings',
    tagline: 'The tide remembers everything.',
    synopsis:
        'Three fishing dynasties wage a silent war over the last wild bay in the North Atlantic.',
    year: 2022,
    rating: 8.8,
    minutes: 56,
    genres: ['Drama'],
    age: 'TV-MA',
    cast: ['Colin Brannagh', "Maeve O'Donnell", 'Jónas Sigurðsson', 'Petra Hansen'],
    series: true,
    seasons: [
      _s(1, ['Nets', 'The Moot', 'Undertow', 'Banishment', 'Herring Season']),
      _s(2, ['Salt Law', "The Widow's Fleet", 'Stormglass', 'Reckoning']),
      _s(3, ['Landfall', 'The Last Moot', 'High Water']),
    ],
    trending: true,
  ),
  _m(
    id: 'echoes-of-sunday',
    title: 'Echoes of Sunday',
    tagline: 'The same Sunday. Again and again.',
    synopsis:
        'A small-town detective relives the day of an unsolved arson until she can prove who lit the match.',
    year: 2024,
    rating: 8.0,
    minutes: 121,
    genres: ['Mystery'],
    cast: ['Harriet Blum', 'Kwame Mensah', 'Sofia Ricci'],
    isNew: true,
  ),
  _m(
    id: 'orbit-cafe',
    title: 'Orbit Café',
    tagline: 'Espresso at escape velocity.',
    synopsis:
        'A girl and her robot uncle run the only café straddling the edge of a wormhole.',
    year: 2024,
    rating: 8.4,
    minutes: 24,
    genres: ['Animation', 'Fantasy'],
    age: 'TV-Y7',
    cast: ['Voices of Mei Kurosaki', 'Barnaby Finch', 'Greta Alves'],
    series: true,
    seasons: [
      _s(1, ['Opening Day', 'The Spilled Star', 'Table for One (Billion)', 'Closing Time', 'Last Orders']),
    ],
    isNew: true,
  ),
  _m(
    id: 'the-cartographers-daughter',
    title: "The Cartographer's Daughter",
    tagline: 'Some maps draw you.',
    synopsis:
        "A mapmaker's daughter follows her mother's unfinished atlas into a valley that redraws itself every night.",
    year: 2023,
    rating: 8.5,
    minutes: 134,
    genres: ['Adventure', 'Fantasy'],
    age: 'PG',
    cast: ['Isla Fenwick', 'Amara Diallo', 'Viktor Havel'],
  ),
  _m(
    id: 'nightsharp',
    title: 'Nightsharp',
    tagline: 'Every city has a blade.',
    synopsis:
        "A locksmith who can open anything is pulled into the one job she swore she'd never take.",
    year: 2025,
    rating: 8.9,
    minutes: 48,
    genres: ['Thriller'],
    age: 'TV-MA',
    cast: ['Nika Volkova', 'Damián Ortiz', 'Ruth Ekwueme'],
    series: true,
    seasons: [
      _s(1, ['Lockpicks', 'The Tenant', 'Master Key', 'Deadbolt', 'Skeleton Key', 'Turn']),
    ],
    trending: true,
    isNew: true,
  ),
  _m(
    id: 'feral-garden',
    title: 'Feral Garden',
    tagline: 'Nature reclaims the nursery.',
    synopsis:
        'Botanists document a greenhouse left wild for thirty years — and the species nobody planted.',
    year: 2022,
    rating: 7.7,
    minutes: 78,
    genres: ['Documentary'],
    age: 'PG',
    cast: ['Featuring Dr. Lena Hartwig'],
  ),
  _m(
    id: 'cinder-bloom',
    title: 'Cinder Bloom',
    tagline: 'From ash, a garden of war.',
    synopsis:
        "A blacksmith's apprentice discovers her forge-fire grows flowers that grant dangerous bargains.",
    year: 2024,
    rating: 8.1,
    minutes: 129,
    genres: ['Fantasy'],
    cast: ['Zoya Petrova', 'Callum Reyes', 'Nia Farrow'],
    isNew: true,
  ),
  _m(
    id: 'static',
    title: 'Static',
    tagline: 'Do not adjust your set.',
    synopsis:
        'A late-night broadcast engineer realizes the interference is answering her.',
    year: 2023,
    rating: 7.2,
    minutes: 96,
    genres: ['Horror', 'Thriller'],
    age: 'TV-MA',
    cast: ['Dana Whitlock', 'Oskar Lindgren'],
  ),
  _m(
    id: 'the-understudy',
    title: 'The Understudy',
    tagline: 'Break a leg. Any leg.',
    synopsis:
        'A theater understudy gets her shot on opening night — and the lead actress never comes back.',
    year: 2025,
    rating: 8.3,
    minutes: 117,
    genres: ['Drama', 'Thriller'],
    cast: ['Camille Aubert', 'Tobias Wren', 'Franka Meyer'],
    isNew: true,
  ),
  _m(
    id: 'marrow-and-sky',
    title: 'Marrow & Sky',
    tagline: 'Bone-deep magic.',
    synopsis:
        'Two bone-rider siblings ferry souls across a sky-archipelago where the wind eats memories.',
    year: 2022,
    rating: 8.7,
    minutes: 51,
    genres: ['Fantasy'],
    age: 'TV-14',
    cast: ['Ines Beaumont', 'Rafael Duarte', 'Olda Kristensen'],
    series: true,
    seasons: [
      _s(1, ['First Flight', 'The Hollow Wind', 'Skyfall Market', 'Bonepickers', 'The Long Dark']),
      _s(2, ['Stormherd', 'The Weight of Names', 'Featherfall', 'Horizon']),
    ],
    trending: true,
  ),
  _m(
    id: 'voltaic',
    title: 'Voltaic',
    tagline: 'Charged and dangerous.',
    synopsis:
        "An ex-electrician gains the city's grid in her fingertips and becomes its most wanted surge.",
    year: 2024,
    rating: 7.4,
    minutes: 108,
    genres: ['Action', 'Sci-Fi'],
    cast: ['Tessa Onyango', 'Marco Feri', 'Jin Bae'],
  ),
  _m(
    id: 'the-quiet-fathom',
    title: 'The Quiet Fathom',
    tagline: 'Ten thousand meters of silence.',
    synopsis:
        'The first all-deaf dive team attempts the deepest mapped trench on Earth.',
    year: 2025,
    rating: 9.0,
    minutes: 92,
    genres: ['Documentary'],
    age: 'PG',
    cast: ['Featuring the Pallas Deep Team'],
    trending: true,
    isNew: true,
  ),
  _m(
    id: 'juniper-lane',
    title: 'Juniper Lane',
    tagline: 'Wrong address. Right person.',
    synopsis:
        'A misdelivered wedding cake entangles two neighbors in a summer of apologies.',
    year: 2023,
    rating: 7.1,
    minutes: 98,
    genres: ['Comedy', 'Romance'],
    age: 'PG',
    cast: ['Holly Stam', 'Nikola Petrov', 'Bea Lim'],
  ),
  _m(
    id: 'half-past-nowhere',
    title: 'Half Past Nowhere',
    tagline: 'Lost is a state of mind.',
    synopsis:
        'A night bus driver and her four stray passengers take the longest shortcut in the world.',
    year: 2024,
    rating: 7.3,
    minutes: 94,
    genres: ['Comedy'],
    cast: ['Mo Adebayo', 'Sanne de Vries', 'Teddy Ortiz'],
    isNew: true,
  ),
  _m(
    id: 'iron-meridian',
    title: 'Iron Meridian',
    tagline: 'The line must hold.',
    synopsis:
        "A railway battalion defends the world's last train line across a frozen continent.",
    year: 2022,
    rating: 8.4,
    minutes: 54,
    genres: ['Action', 'Adventure'],
    age: 'TV-14',
    cast: ['Greta Sundberg', 'Aleksy Nowak', 'Dube Moyo'],
    series: true,
    seasons: [
      _s(1, ['First Snow', 'The Switchback', 'Iron Winter', 'Junction']),
      _s(2, ['Steel and Salt', 'The Long Grade', 'Terminus']),
    ],
    trending: true,
  ),
  _m(
    id: 'pale-constellations',
    title: 'Pale Constellations',
    tagline: 'Grief, measured in light-years.',
    synopsis:
        'A xenolinguist keeps translating messages from a ship that never launched.',
    year: 2023,
    rating: 8.9,
    minutes: 141,
    genres: ['Sci-Fi', 'Drama'],
    cast: ['Vera Almeida', 'Henrik Falk', 'Sanaya Kapur'],
    trending: true,
  ),
  _m(
    id: 'the-velvet-fox',
    title: 'The Velvet Fox',
    tagline: 'Clever is a kind of courage.',
    synopsis:
        'A museum fox carved from velvet wakes at midnight to return everything the museum stole.',
    year: 2022,
    rating: 8.6,
    minutes: 102,
    genres: ['Animation'],
    age: 'G',
    cast: ['Voices of Odette Marchand', 'Basil Wu'],
  ),
  _m(
    id: 'deep-signal',
    title: 'Deep Signal',
    tagline: 'The ocean is dialing back.',
    synopsis:
        'A sonar technician discovers the deep sea is answering her pings — in morse.',
    year: 2025,
    rating: 8.2,
    minutes: 49,
    genres: ['Mystery', 'Sci-Fi'],
    age: 'TV-14',
    cast: ['Maja Sørensen', 'Caleb Adjei', 'Rina Vasquez'],
    series: true,
    seasons: [
      _s(1, ['Ping', 'The Trough', 'Sonar Ghosts', 'Pressure', 'Surface']),
    ],
    isNew: true,
  ),
  _m(
    id: 'gravitys-lullaby',
    title: "Gravity's Lullaby",
    tagline: 'Sleep is a kind of falling.',
    synopsis:
        "A station insomniac discovers the crew's dreams are leaking into the air system.",
    year: 2022,
    rating: 7.6,
    minutes: 126,
    genres: ['Sci-Fi'],
    cast: ['Noor Rahimi', 'Petar Volkov', 'Elif Demir'],
  ),
  _m(
    id: 'the-bells-of-cahors',
    title: 'The Bells of Cahors',
    tagline: 'A town rings for its missing.',
    synopsis:
        'Every evening a French village rings bells for a girl no one admits to knowing.',
    year: 2021,
    rating: 8.5,
    minutes: 119,
    genres: ['Drama'],
    age: 'PG',
    cast: ['Josette Martin', 'Émile Roux', 'Camille Thom'],
  ),
  _m(
    id: 'riptide-city',
    title: 'Riptide City',
    tagline: 'The streets pull you under.',
    synopsis:
        "A swim coach moonlights as the harbor's most improbable getaway driver.",
    year: 2023,
    rating: 7.0,
    minutes: 106,
    genres: ['Action'],
    cast: ['Duke Ferrara', 'Anna Kessel', 'Rui Costa'],
  ),
  _m(
    id: 'wildland',
    title: 'Wildland',
    tagline: 'The map ends here.',
    synopsis:
        'Four rangers patrol a million hectares of taiga that officially does not exist.',
    year: 2024,
    rating: 7.8,
    minutes: 88,
    genres: ['Documentary', 'Adventure'],
    age: 'PG',
    cast: ['Featuring Ranger Unit 7'],
    isNew: true,
  ),
];
