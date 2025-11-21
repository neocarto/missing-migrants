export function toGeoJSON(data) {
  const features = data.map((d) => ({
    type: "Feature",
    properties: { ...d },
    geometry: {
      type: "Point",
      coordinates: [parseFloat(d.lng), parseFloat(d.lat)],
    },
  }));

  return {
    type: "FeatureCollection",
    features,
  };
}
