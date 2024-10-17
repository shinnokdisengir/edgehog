#
# This file is part of Edgehog.
#
# Copyright 2024 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#

defmodule Edgehog.Repo.Migrations.CreateApplications do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:applications, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :description, :text

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :tenant_id,
          references(:tenants,
            column: :tenant_id,
            name: "applications_tenant_id_fkey",
            type: :bigint,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false
    end

    create index(:applications, [:tenant_id])

    create index(:applications, [:id, :tenant_id], unique: true)

    create unique_index(:applications, [:tenant_id, :name], name: "applications_name_index")
  end

  def down do
    drop_if_exists unique_index(:applications, [:tenant_id, :name],
                     name: "applications_name_index"
                   )

    drop constraint(:applications, "applications_tenant_id_fkey")

    drop_if_exists index(:applications, [:id, :tenant_id])

    drop_if_exists index(:applications, [:tenant_id])

    drop table(:applications)
  end
end
