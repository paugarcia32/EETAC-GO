/* eslint-disable quotes */
import { Schema, model } from "mongoose";

import { Itinerario } from "../interfaces/itinerario.interface";

const ItinerarioSchema = new Schema<Itinerario>(
    {
        name: {
            type: String,
            required: true,
        },
        descr: {
            type: String,
            required: true,
        },
        challenges: {
            type: [Schema.Types.ObjectId],
            ref: 'challenges',
        },
        insignia: {
            type: String,
            required: false
        }
    },
    {
        timestamps: true,
        versionKey: false,
    }
);

const ItinerarioModel = model('itinerarios', ItinerarioSchema);

export default ItinerarioModel;