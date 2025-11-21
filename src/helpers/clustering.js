import { clustersDbscan as clust } from "@turf/clusters-dbscan";
import { clusterReduce } from "@turf/clusters";
import { max, sum } from "d3-array";

export function clustering(
  featurcollection,
  maxdistancekm = 100,
  type = "All"
) {
  let clustersDbscan = clust(featurcollection, maxdistancekm);

  let core = {
    type: "FeatureCollection",
    features: clustersDbscan.features.filter(
      (d) => d.properties.dbscan == "core"
    ),
  };

  let noise = clustersDbscan.features
    .filter((d) => d.properties.dbscan == "noise")
    .map((d) => ({
      type: "Feature",
      properties: {
        type: type,
        dbscan: "noise",
        count: 1,
        nb: d.properties.nb,
      },
      //geometry: d.geometry
      geometry: {
        type: "Point",
        coordinates: fuzzy(d.geometry.coordinates),
      },
    }));

  let clusters = clusterReduce(
    core,
    "cluster",
    function (acc, cluster) {
      acc.push(cluster);
      return acc;
    },
    []
  );

  let centers = clusters.map((d) => {
    let c = d.features;
    let arr = c.map((d) => d.properties.nb);
    let index = arr.indexOf(max(arr));
    let coords = c[index].geometry;

    return {
      type: "Feature",
      properties: {
        type: type,
        dbscan: "core",
        count: c.length,
        nb: sum(c.map((d) => d.properties.nb)),
      },
      geometry: {
        type: "Point",
        coordinates: fuzzy(coords.coordinates),
      },
      //geometry: coords
    };
  });

  let final = { type: "FeatureCollection", features: centers.concat(noise) };

  return final;
}

function fuzzy(coords, delta = 0.2) {
  return [
    coords[0] + (Math.random() - 0.5) * 2 * delta,
    coords[1] + (Math.random() - 0.5) * 2 * delta,
  ];
}
