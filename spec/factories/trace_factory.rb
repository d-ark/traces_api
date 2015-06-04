module TracesApi

  FactoryGirl.define do
    factory :trace1, class: Trace do
      value [
        {"latitude":32.9377784729004,"longitude":-117.230392456055},
        {"latitude":32.937801361084,"longitude":-117.230323791504},
        {"latitude":32.9378204345703,"longitude":-117.230278015137}
      ]
    end
    factory :trace2, class: Trace do
      value [
        {"latitude":62.9377784729004,"longitude":-115.230392456055},
        {"latitude":62.937801361084,"longitude":-115.230323791504}
      ]
    end
    factory :trace3, class: Trace do
      value [
        {"latitude":94.9377784729004,"longitude":-17.230392456055},
        {"latitude":94.937801361084,"longitude":-17.230323791504},
        {"latitude":94.9378204345703,"longitude":-17.230278015137}
      ]
    end
  end

end
