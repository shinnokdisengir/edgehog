#
# This file is part of Edgehog.
#
# Copyright 2021-2024 SECO Mind Srl
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

defmodule EdgehogWeb.Schema.Query.DeviceTest do
  use EdgehogWeb.GraphqlCase, async: true

  @moduletag :ported_to_ash

  import Edgehog.DevicesFixtures

  alias Edgehog.Devices

  describe "device query" do
    test "returns device if present", %{tenant: tenant} do
      fixture = device_fixture(tenant: tenant)

      id = AshGraphql.Resource.encode_relay_id(fixture)

      device =
        device_query(tenant: tenant, id: id)
        |> extract_result!()

      assert device["name"] == fixture.name
      assert device["deviceId"] == fixture.device_id
      assert device["online"] == fixture.online
    end

    test "returns nil if non existing", %{tenant: tenant} do
      id = non_existing_device_id(tenant)
      result = device_query(tenant: tenant, id: id)
      assert %{data: %{"device" => nil}} = result
    end
  end

  defp non_existing_device_id(tenant) do
    fixture = device_fixture(tenant: tenant)
    id = AshGraphql.Resource.encode_relay_id(fixture)
    :ok = Devices.destroy!(fixture)

    id
  end

  defp device_query(opts) do
    default_document = """
    query ($id: ID!) {
      device(id: $id) {
        name
        deviceId
        online
      }
    }
    """

    tenant = Keyword.fetch!(opts, :tenant)
    id = Keyword.fetch!(opts, :id)

    variables = %{"id" => id}

    document = Keyword.get(opts, :document, default_document)

    Absinthe.run!(document, EdgehogWeb.Schema, variables: variables, context: %{tenant: tenant})
  end

  defp extract_result!(result) do
    refute :errors in Map.keys(result)
    assert %{data: %{"device" => device}} = result
    assert device != nil

    device
  end
end
