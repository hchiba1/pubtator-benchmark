shellPrint(
  db.bc2pubtator.aggregate([
    { $match: { Species: {$in: [{"id": "9606"}]}}},
    // { $match: { "Species.id": "9606"}},
    { $unwind: "$Gene" },
    { $group: { _id: "$Gene", count: {$sum: 1}}},
    { $sort: {count: -1} }
  ]
  , { allowDiskUse: true }
  ));
